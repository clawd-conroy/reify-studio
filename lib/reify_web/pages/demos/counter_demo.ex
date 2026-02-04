defmodule ReifyWeb.Pages.Demos.CounterDemo do
  @moduledoc """
  LiveView that demonstrates React integration via live_react.

  This is intentionally boring. The entire server-side logic fits in ~40 lines.
  No cleverness. No magic. Just:

    1. mount/3 - Initialize state
    2. handle_event/3 - Receive events from React, update state
    3. render/1 - Pass state to React as props

  When assigns change, live_react automatically re-renders the React component
  with new props. That's it. That's the whole pattern.

  ## The Mental Model

      React          LiveView         Assigns
        |               |               |
        |--pushEvent--->|               |
        |               |--update------>|
        |               |               |
        |<--new props---|<--render------|

  Events flow up (pushEvent). Props flow down (assigns -> React props).
  No REST. No GraphQL. No cache invalidation. Just WebSocket.
  """
  use ReifyWeb, :live_view

  # --- Mount: Initialize State ---
  # These assigns become React props automatically via live_react.
  # When they change, React re-renders. No manual prop passing needed.

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "Counter Demo",
       count: 0,
       error: nil,
       response_id: Reify.Utils.short_id()
     )}
  end

  # --- Event Handlers: Receive Events from React ---
  # React calls `pushEvent("ping", { mode: "slow" })`.
  # LiveView pattern-matches on the event name and payload.
  # That's the entire client->server communication model.

  @impl true
  def handle_event("ping", %{"mode" => "error"}, socket) do
    # Simulate slow server to demo optimistic UI
    Process.sleep(1000)
    {:noreply, increment_response(socket, error: true)}
  end

  @impl true
  def handle_event("ping", %{"mode" => "slow"}, socket) do
    # Simulate slow server to demo optimistic UI
    Process.sleep(1000)
    {:noreply, increment_count(socket)}
  end

  @impl true
  def handle_event("ping", _params, socket) do
    {:noreply, increment_count(socket)}
  end

  # --- Private Helpers: Update State ---
  # Nothing fancy. Just update assigns. LiveView handles the rest.

  defp increment_count(socket) do
    socket
    |> assign(count: socket.assigns.count + 1, error: false)
    |> increment_response()
  end

  defp increment_response(socket, opts \\ []) do
    error = Keyword.get(opts, :error, socket.assigns.error)
    assign(socket, error: error, response_id: Reify.Utils.short_id())
  end

  # --- Render: One Line ---
  # The entire UI is a single React component. Assigns become props.
  # live_react handles serialization, diffing, and re-rendering.

  @impl true
  def render(assigns) do
    ~H"""
    <.react name="CounterDemoLayout" count={@count} error={@error} responseId={@response_id} />
    """
  end
end
