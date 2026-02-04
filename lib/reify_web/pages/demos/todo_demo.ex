defmodule ReifyWeb.Pages.Demos.TodoDemo do
  @moduledoc """
  LiveView for the Todos demo.

  This LiveView uses the EventRouter pattern to delegate all event handling
  to Event Command modules in `Reify.Demos.Todos.Events`.

  The LiveView is responsible for:
  1. Mounting initial state
  2. Defining how to reload state after events
  3. Rendering the React component

  Event handling logic lives in the Event Commands, not here.
  """
  use ReifyWeb, :live_view
  use Reify.EventRouter, events: Reify.Demos.Todos.Events

  alias Reify.Demos.Todos

  @impl true
  def mount(_params, _session, socket) do
    todos = load_todos()

    {:ok,
     assign(socket, page_title: "Todos Demo", todos: todos, response_id: Reify.Utils.short_id())}
  end

  @doc """
  Reload state after any successful event.

  Called by the EventRouter after an Event Command succeeds.
  This is the LiveView's main job - managing the socket state.
  """
  def reload_state(socket) do
    socket
    |> assign(response_id: Reify.Utils.short_id())
    |> assign(todos: load_todos())
  end

  # --- Private Helpers ---

  defp load_todos do
    case Todos.list_todos() do
      {:ok, todos} ->
        todos

      {:error, error} ->
        require Logger
        Logger.error("Failed to load todos: #{inspect(error)}")
        []
    end
  end

  # --- Render ---

  @impl true
  def render(assigns) do
    ~H"""
    <.react name="TodoDemoLayout" todos={@todos} responseId={@response_id} />
    """
  end
end
