defmodule ReifyStudio.OpenClaw.GatewayClient do
  @moduledoc """
  Client for the OpenClaw Gateway WebSocket API.

  Manages connection lifecycle, RPC requests (chat.send, chat.history,
  chat.abort), and broadcasts gateway events via PubSub.

  ## Configuration

  Expects `:url` and optionally `:token` in the child spec opts.

  ## Events

  Subscribe via `ReifyStudio.OpenClaw.GatewayClient.subscribe/0` to receive:

    - `{:openclaw, :connected, hello}` — gateway connected
    - `{:openclaw, :disconnected, reason}` — gateway disconnected
    - `{:openclaw, :event, event_name, payload, seq}` — gateway event
  """

  use GenServer

  require Logger

  @logger_metadata [context: "openclaw.gateway"]

  alias Phoenix.PubSub
  alias ReifyStudio.OpenClaw.GatewayWs

  @pubsub ReifyStudio.PubSub
  @topic "openclaw:events"
  @request_timeout 30_000

  # --- Public API ---

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc "Send a chat message to the gateway."
  def send_chat(session_key, message, opts \\ []) do
    GenServer.call(__MODULE__, {:send_chat, session_key, message, opts}, @request_timeout)
  end

  @doc "Load chat history for a session."
  def load_history(session_key, opts \\ []) do
    GenServer.call(__MODULE__, {:load_history, session_key, opts}, @request_timeout)
  end

  @doc "Abort a running chat."
  def abort_chat(session_key, run_id) do
    GenServer.call(__MODULE__, {:abort_chat, session_key, run_id}, @request_timeout)
  end

  @doc "Get gateway status."
  def get_status do
    GenServer.call(__MODULE__, :get_status, @request_timeout)
  end

  @doc "Check if connected to gateway."
  def connected? do
    GenServer.call(__MODULE__, :connected?)
  end

  @doc "Subscribe to gateway events via PubSub."
  def subscribe do
    PubSub.subscribe(@pubsub, @topic)
  end

  # --- GenServer Callbacks ---

  @impl true
  def init(opts) do
    Logger.metadata(@logger_metadata)
    url = Keyword.fetch!(opts, :url)
    token = Keyword.get(opts, :token)

    Logger.info("Connecting to OpenClaw gateway at #{url}")

    state = %{
      url: url,
      token: token,
      ws_pid: nil,
      connected: false,
      hello: nil,
      pending_requests: %{},
      seq: 0
    }

    send(self(), :start_ws)
    {:ok, state}
  end

  @impl true
  def handle_call({:send_chat, session_key, message, opts}, from, state) do
    request_id = generate_id()

    params =
      %{"sessionKey" => session_key, "message" => message, "idempotencyKey" => request_id}
      |> maybe_put("thinking", Keyword.get(opts, :thinking))
      |> maybe_put("deliver", Keyword.get(opts, :deliver))

    do_request(state, "chat.send", params, request_id, from)
  end

  @impl true
  def handle_call({:load_history, session_key, opts}, from, state) do
    request_id = generate_id()
    params = %{"sessionKey" => session_key, "limit" => Keyword.get(opts, :limit, 50)}
    do_request(state, "chat.history", params, request_id, from)
  end

  @impl true
  def handle_call({:abort_chat, session_key, run_id}, from, state) do
    request_id = generate_id()
    params = %{"sessionKey" => session_key, "runId" => run_id}
    do_request(state, "chat.abort", params, request_id, from)
  end

  @impl true
  def handle_call(:get_status, from, state) do
    request_id = generate_id()
    do_request(state, "status", %{}, request_id, from)
  end

  @impl true
  def handle_call(:connected?, _from, state) do
    {:reply, state.connected, state}
  end

  @impl true
  def handle_info(:start_ws, state) do
    ws_url = build_ws_url(state.url, state.token)

    case GatewayWs.start_link(uri: ws_url, state: %{parent: self()}) do
      {:ok, pid} ->
        Process.monitor(pid)
        {:noreply, %{state | ws_pid: pid}}

      {:error, reason} ->
        Logger.warning("Failed to start OpenClaw WebSocket: #{inspect(reason)}")
        Process.send_after(self(), :start_ws, 5_000)
        {:noreply, state}
    end
  end

  @impl true
  def handle_info(:ws_connected, state) do
    Logger.info("OpenClaw WebSocket transport ready")
    send_connect_frame(state)
    {:noreply, state}
  end

  @impl true
  def handle_info({:ws_message, frame}, state) do
    case Jason.decode(frame) do
      {:ok, parsed} ->
        handle_frame(parsed, state)

      {:error, _} ->
        Logger.warning("OpenClaw: invalid JSON frame")
        {:noreply, state}
    end
  end

  @impl true
  def handle_info({:ws_closed, code, reason}, state) do
    Logger.warning("OpenClaw gateway disconnected: code=#{code} reason=#{reason}")
    broadcast({:openclaw, :disconnected, reason})
    fail_pending_requests(state, :disconnected)
    {:noreply, %{state | connected: false, hello: nil, pending_requests: %{}}}
  end

  @impl true
  def handle_info({:ws_error, _error}, state) do
    {:noreply, state}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, reason}, %{ws_pid: pid} = state) do
    Logger.warning("OpenClaw WebSocket process died: #{inspect(reason)}")
    broadcast({:openclaw, :disconnected, inspect(reason)})
    fail_pending_requests(state, :ws_died)
    Process.send_after(self(), :start_ws, 5_000)
    {:noreply, %{state | ws_pid: nil, connected: false, hello: nil, pending_requests: %{}}}
  end

  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  # --- Frame Handling ---

  defp handle_frame(%{"type" => "hello-ok"} = hello, state) do
    version = get_in(hello, ["server", "version"]) || "unknown"
    Logger.info("Connected to OpenClaw gateway v#{version}")
    broadcast({:openclaw, :connected, hello})
    {:noreply, %{state | connected: true, hello: hello}}
  end

  defp handle_frame(%{"type" => "event", "event" => "tick"}, state) do
    {:noreply, state}
  end

  defp handle_frame(%{"type" => "event", "event" => name} = evt, state) do
    payload = Map.get(evt, "payload")
    seq = Map.get(evt, "seq")
    broadcast({:openclaw, :event, name, payload, seq})
    {:noreply, %{state | seq: seq || state.seq}}
  end

  defp handle_frame(%{"type" => "res", "id" => id, "ok" => true} = res, state) do
    case Map.pop(state.pending_requests, id) do
      {nil, _} ->
        {:noreply, state}

      {from, pending} ->
        GenServer.reply(from, {:ok, Map.get(res, "payload")})
        {:noreply, %{state | pending_requests: pending}}
    end
  end

  defp handle_frame(%{"type" => "res", "id" => id, "ok" => false} = res, state) do
    case Map.pop(state.pending_requests, id) do
      {nil, _} ->
        {:noreply, state}

      {from, pending} ->
        GenServer.reply(from, {:error, Map.get(res, "error")})
        {:noreply, %{state | pending_requests: pending}}
    end
  end

  defp handle_frame(_frame, state), do: {:noreply, state}

  # --- Helpers ---

  defp do_request(state, method, params, request_id, from) do
    if state.connected && state.ws_pid do
      frame =
        Jason.encode!(%{
          "type" => "req",
          "id" => request_id,
          "method" => method,
          "params" => params
        })

      Fresh.send(state.ws_pid, {:text, frame})
      pending = Map.put(state.pending_requests, request_id, from)
      {:noreply, %{state | pending_requests: pending}}
    else
      {:reply, {:error, :not_connected}, state}
    end
  end

  defp send_connect_frame(state) do
    connect_params = %{
      "minProtocol" => 1,
      "maxProtocol" => 1,
      "client" => %{
        "id" => "reify-studio",
        "displayName" => "Reify Studio",
        "version" => "0.1.0",
        "platform" => "elixir",
        "mode" => "ui",
        "instanceId" => generate_id()
      }
    }

    connect_params =
      if state.token do
        Map.put(connect_params, "auth", %{"token" => state.token})
      else
        connect_params
      end

    frame =
      Jason.encode!(%{
        "type" => "req",
        "id" => generate_id(),
        "method" => "connect",
        "params" => connect_params
      })

    Fresh.send(state.ws_pid, {:text, frame})
  end

  defp build_ws_url(base_url, _token) do
    base_url
  end

  defp fail_pending_requests(state, reason) do
    for {_id, from} <- state.pending_requests do
      GenServer.reply(from, {:error, reason})
    end
  end

  defp broadcast(msg) do
    PubSub.broadcast(@pubsub, @topic, msg)
  end

  defp generate_id do
    :crypto.strong_rand_bytes(16) |> Base.encode16(case: :lower)
  end

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)
end
