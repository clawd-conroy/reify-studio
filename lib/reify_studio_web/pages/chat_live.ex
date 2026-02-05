defmodule ReifyStudioWeb.Pages.ChatLive do
  @moduledoc """
  LiveView chat interface connected to the OpenClaw Gateway.

  Provides real-time chat with streaming agent responses.
  """

  use ReifyStudioWeb, :live_view

  alias ReifyStudio.OpenClaw.GatewayClient

  @session_key "agent:main:main"

  @impl true
  def mount(_params, _session, socket) do
    gateway_connected =
      if connected?(socket) do
        GatewayClient.subscribe()
        send(self(), :load_history)
        GatewayClient.connected?()
      else
        false
      end

    {:ok,
     assign(socket,
       page_title: "Chat",
       messages: [],
       input: "",
       connected: gateway_connected,
       loading: true,
       streaming: false,
       stream_buffer: ""
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col h-screen max-w-4xl mx-auto">
      <%!-- Header --%>
      <div class="navbar bg-base-200 px-4">
        <div class="flex-1">
          <h1 class="text-xl font-bold">Reify Studio</h1>
        </div>
        <div class="flex-none">
          <div class={[
            "badge",
            if(@connected, do: "badge-success", else: "badge-error")
          ]}>
            {if @connected, do: "Connected", else: "Disconnected"}
          </div>
        </div>
      </div>

      <%!-- Messages --%>
      <div
        id="messages"
        class="flex-1 overflow-y-auto p-4 space-y-4"
        phx-hook="ScrollBottom"
      >
        <div :if={@loading} class="flex justify-center py-8">
          <span class="loading loading-spinner loading-lg"></span>
        </div>

        <div :for={msg <- @messages} class={message_classes(msg)}>
          <div class={[
            "chat-bubble",
            if(msg.role == "user", do: "chat-bubble-primary", else: "")
          ]}>
            <div class="whitespace-pre-wrap">{msg.content}</div>
          </div>
          <div :if={msg.timestamp} class="chat-footer opacity-50 text-xs">
            {format_time(msg.timestamp)}
          </div>
        </div>

        <div :if={@streaming} class="chat chat-start">
          <div class="chat-bubble">
            <div class="whitespace-pre-wrap">{@stream_buffer}</div>
            <span class="loading loading-dots loading-xs"></span>
          </div>
        </div>
      </div>

      <%!-- Input --%>
      <div class="p-4 bg-base-200">
        <form phx-submit="send_message" phx-change="update_input" class="flex gap-2">
          <input
            type="text"
            name="message"
            value={@input}
            placeholder="Type a message..."
            class="input input-bordered flex-1 text-lg"
            autocomplete="off"
            disabled={!@connected}
          />
          <button
            type="submit"
            class="btn btn-primary"
            disabled={!@connected || @input == ""}
          >
            Send
          </button>
        </form>
      </div>
    </div>
    """
  end

  # --- Event Handlers ---

  @impl true
  def handle_event("send_message", %{"message" => message}, socket) when message != "" do
    user_msg = %{role: "user", content: message, timestamp: DateTime.utc_now()}

    Task.start(fn ->
      GatewayClient.send_chat(@session_key, message)
    end)

    {:noreply,
     socket
     |> update(:messages, &(&1 ++ [user_msg]))
     |> assign(input: "", streaming: true, stream_buffer: "")}
  end

  @impl true
  def handle_event("send_message", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("update_input", %{"message" => value}, socket) do
    {:noreply, assign(socket, input: value)}
  end

  # --- PubSub Handlers ---

  @impl true
  def handle_info({:openclaw, :connected, _hello}, socket) do
    send(self(), :load_history)
    {:noreply, assign(socket, connected: true)}
  end

  @impl true
  def handle_info({:openclaw, :disconnected, _reason}, socket) do
    {:noreply, assign(socket, connected: false)}
  end

  @impl true
  def handle_info({:openclaw, :event, "chat", payload, _seq}, socket) do
    handle_chat_event(payload, socket)
  end

  @impl true
  def handle_info({:openclaw, :event, _name, _payload, _seq}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info(:load_history, socket) do
    case GatewayClient.load_history(@session_key, limit: 100) do
      {:ok, %{"messages" => messages}} ->
        parsed =
          messages
          |> Enum.map(&parse_history_message/1)
          |> Enum.reject(&is_nil/1)

        {:noreply, assign(socket, messages: parsed, loading: false, connected: true)}

      {:ok, _} ->
        {:noreply, assign(socket, loading: false, connected: true)}

      {:error, _reason} ->
        {:noreply, assign(socket, loading: false)}
    end
  end

  @impl true
  def handle_info(_msg, socket) do
    {:noreply, socket}
  end

  # --- Chat Event Handling ---

  # Final message — the complete response
  defp handle_chat_event(%{"state" => "final", "message" => message}, socket)
       when is_map(message) do
    text = extract_text(message)

    if text && text != "" do
      msg = %{role: "assistant", content: text, timestamp: DateTime.utc_now()}

      {:noreply,
       socket
       |> update(:messages, &(&1 ++ [msg]))
       |> assign(streaming: false, stream_buffer: "")}
    else
      {:noreply, assign(socket, streaming: false, stream_buffer: "")}
    end
  end

  defp handle_chat_event(%{"state" => "final"}, socket) do
    {:noreply, assign(socket, streaming: false, stream_buffer: "")}
  end

  # Error
  defp handle_chat_event(%{"state" => "error", "errorMessage" => err}, socket) do
    msg = %{role: "assistant", content: "⚠️ Error: #{err}", timestamp: DateTime.utc_now()}

    {:noreply,
     socket
     |> update(:messages, &(&1 ++ [msg]))
     |> assign(streaming: false, stream_buffer: "")}
  end

  # Ignore deltas for now (streaming chunks)
  defp handle_chat_event(%{"state" => "delta"}, socket) do
    {:noreply, socket}
  end

  defp handle_chat_event(_payload, socket) do
    {:noreply, socket}
  end

  defp extract_text(%{"content" => [%{"type" => "text", "text" => text} | _]}), do: text
  defp extract_text(%{"content" => content}) when is_binary(content), do: content
  defp extract_text(_), do: nil

  # --- Helpers ---

  defp parse_history_message(%{"role" => role, "content" => content})
       when role in ["user", "assistant"] and is_binary(content) do
    %{role: role, content: content, timestamp: nil}
  end

  defp parse_history_message(_), do: nil

  defp message_classes(msg) do
    case msg.role do
      "user" -> "chat chat-end"
      _ -> "chat chat-start"
    end
  end

  defp format_time(nil), do: nil

  defp format_time(%DateTime{} = dt) do
    Calendar.strftime(dt, "%H:%M")
  end
end
