defmodule ReifyStudio.OpenClaw.GatewayWs do
  @moduledoc """
  Fresh-based WebSocket connection to the OpenClaw Gateway.

  Handles the raw WebSocket framing and forwards messages to the
  GatewayClient GenServer via PubSub.
  """

  use Fresh

  require Logger

  @impl Fresh
  def handle_connect(_status, _headers, state) do
    Logger.debug("OpenClaw WebSocket transport connected")
    send(state.parent, :ws_connected)
    {:ok, state}
  end

  @impl Fresh
  def handle_in({:text, frame}, state) do
    send(state.parent, {:ws_message, frame})
    {:ok, state}
  end

  @impl Fresh
  def handle_in(_frame, state) do
    {:ok, state}
  end

  @impl Fresh
  def handle_disconnect(code, reason, state) do
    send(state.parent, {:ws_closed, code, reason || "unknown"})
    {:reconnect, state}
  end

  @impl Fresh
  def handle_error(error, state) do
    Logger.warning("OpenClaw WebSocket error: #{inspect(error)}")
    send(state.parent, {:ws_error, error})
    {:reconnect, state}
  end

  @impl Fresh
  def handle_info(_msg, state) do
    {:ok, state}
  end
end
