defmodule ReifyStudio.EventRouter do
  @moduledoc """
  Event routing for LiveView using Ash Resources.

  Routes events to actions on an Ash Event Resource.

  ## Usage

      defmodule ReifyStudioWeb.Pages.Demos.Todos do
        use ReifyStudioWeb, :live_view
        use ReifyStudio.EventRouter, events: ReifyStudio.Demos.Todos.Events

        def reload_state(socket) do
          assign(socket, todos: ReifyStudio.Demos.Todos.list_todos!())
        end
      end

  This generates `handle_event/3` clauses that:
  1. Convert "create_todo" → :create_todo action
  2. Call the action on the Events resource
  3. On success: call `reload_state/1` and push success event
  4. On error: push error event
  5. Unknown actions: log warning and push generic error
  """

  require Logger

  defmacro __using__(opts) do
    events_module = Keyword.fetch!(opts, :events)

    quote do
      @events_module unquote(events_module)

      @impl true
      def handle_event(event_name, params, socket) do
        ReifyStudio.EventRouter.dispatch(
          event_name,
          params,
          socket,
          @events_module,
          &reload_state/1
        )
      end

      # Default reload_state - should be overridden
      def reload_state(socket), do: socket

      defoverridable reload_state: 1
    end
  end

  @doc """
  Dispatch an event to an action on the Events resource.
  """
  def dispatch(event_name, params, socket, events_module, reload_fn) do
    action = String.to_existing_atom(event_name)
    actor = socket.assigns[:current_user]

    # Convert camelCase params from TypeScript to snake_case for Ash
    input = normalize_params(params)

    Logger.debug([
      IO.ANSI.blue(),
      "⬇ CLIENT EVENT ",
      IO.ANSI.cyan(),
      "\"#{event_name}\" ",
      IO.ANSI.reset(),
      inspect(input)
    ])

    result =
      events_module
      |> Ash.ActionInput.for_action(action, input)
      |> Ash.run_action(actor: actor)

    case result do
      {:ok, data} ->
        success_event = events_module.success_event(event_name)
        payload = result_to_map(data)

        Logger.debug([
          IO.ANSI.green(),
          "⬆ SERVER EVENT ",
          IO.ANSI.light_green(),
          "\"#{success_event}\" ",
          IO.ANSI.reset(),
          inspect(payload)
        ])

        socket =
          socket
          |> reload_fn.()
          |> Phoenix.LiveView.push_event(success_event, payload)

        {:noreply, socket}

      {:error, error} ->
        error_payload = ReifyStudio.Events.format_error(event_name, error)

        Logger.debug([
          IO.ANSI.red(),
          "⬆ SERVER ERROR ",
          IO.ANSI.light_red(),
          "\"#{event_name}\" ",
          IO.ANSI.reset(),
          inspect(error_payload)
        ])

        socket =
          Phoenix.LiveView.push_event(
            socket,
            "error",
            error_payload
          )

        {:noreply, socket}
    end
  rescue
    ArgumentError ->
      handle_unknown_event(event_name, params, socket)
  end

  # Convert params from camelCase (TypeScript) to snake_case (Elixir)
  # Handles both flat params and legacy nested params
  defp normalize_params(params) do
    Enum.reduce(params, %{}, fn
      # Legacy nested format: %{"todo" => %{"id" => x}} -> %{todo_id: x}
      {parent_key, %{} = nested}, acc ->
        prefix = to_snake_case(parent_key)

        nested
        |> Enum.map(fn {k, v} ->
          prefixed_key = "#{prefix}_#{to_snake_case(k)}"
          {String.to_existing_atom(prefixed_key), v}
        end)
        |> Enum.into(acc)

      # Flat format: %{"todoId" => x} -> %{todo_id: x}
      {key, value}, acc ->
        Map.put(acc, String.to_existing_atom(to_snake_case(key)), value)
    end)
  rescue
    ArgumentError -> params
  end

  # Convert camelCase to snake_case
  defp to_snake_case(key) when is_binary(key) do
    key
    |> String.replace(~r/([a-z])([A-Z])/, "\\1_\\2")
    |> String.downcase()
  end

  # Handle unknown events with logging and generic error
  defp handle_unknown_event(event_name, params, socket) do
    Logger.warning(
      "Unknown event received: #{event_name} params=#{inspect(Map.keys(params))} view=#{inspect(socket.view)}"
    )

    socket =
      Phoenix.LiveView.push_event(socket, "error", %{
        source: event_name,
        code: "unknown_event",
        message: "Sorry, an error occurred. Please try again."
      })

    {:noreply, socket}
  end

  # Convert result to a JSON-encodable value for push_event.
  # Structs MUST implement Jason.Encoder (via AshJason or @derive) to control
  # which fields are serialized. We don't use Map.from_struct to avoid
  # accidentally exposing private fields.
  defp result_to_map(%{} = map), do: map

  defp result_to_map(struct) when is_struct(struct) do
    if has_jason_encoder?(struct) do
      struct
    else
      raise ArgumentError, """
      Struct #{inspect(struct.__struct__)} does not implement Jason.Encoder.

      Add `use AshJason.Resource` to Ash resources, or add:
        @derive Jason.Encoder
      to explicitly control JSON serialization.
      """
    end
  end

  defp result_to_map(other), do: %{result: other}

  defp has_jason_encoder?(struct) do
    Jason.Encoder.impl_for(struct) != Jason.Encoder.Any
  end
end
