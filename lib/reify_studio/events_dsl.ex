defmodule ReifyStudio.EventsDsl do
  @moduledoc """
  DSL for defining bidirectional events between client and server.

  ## Usage

      defmodule MyApp.Todos.Events do
        use Ash.Resource, domain: MyApp.Todos
        use ReifyStudio.EventsDsl

        client_events do
          event :create_todo, payload: %{title: :string} do
            MyApp.Todos.create_todo(title)
          end
        end

        server_events do
          event :todo_created, payload: MyApp.Todos.Todo
        end
      end
  """

  defmacro __using__(_opts) do
    quote do
      import ReifyStudio.EventsDsl
      Module.register_attribute(__MODULE__, :reify_studio_client_events, accumulate: true)
      Module.register_attribute(__MODULE__, :reify_studio_server_events, accumulate: true)
      @before_compile ReifyStudio.EventsDsl
    end
  end

  @doc """
  Define events that the client can send to the server.
  """
  defmacro client_events(do: block) do
    # Extract event definitions from the block
    events = extract_client_events(block)

    # Generate actions for each event
    action_defs = Enum.map(events, &generate_client_action/1)

    quote do
      # Register all client events
      unquote_splicing(
        Enum.map(events, fn {name, payload, emits, _block} ->
          quote do
            @reify_studio_client_events {unquote(name), unquote(Macro.escape(payload)), unquote(emits)}
          end
        end)
      )

      # Generate Ash actions
      actions do
        (unquote_splicing(action_defs))
      end
    end
  end

  @doc """
  Define events that the server can send to the client.
  """
  defmacro server_events(do: block) do
    events = extract_server_events(block)

    quote do
      (unquote_splicing(
         Enum.map(events, fn {name, payload} ->
           quote do
             @reify_studio_server_events {unquote(name), unquote(Macro.escape(payload))}
           end
         end)
       ))
    end
  end

  # Parse client_events block to extract {name, payload, emits, handler_block} tuples
  defp extract_client_events({:__block__, _, items}), do: Enum.map(items, &parse_client_event/1)
  defp extract_client_events(single), do: [parse_client_event(single)]

  defp parse_client_event({:event, _, [name, opts, [do: block]]}) do
    payload = Keyword.fetch!(opts, :payload)
    emits = Keyword.get(opts, :emits)
    {name, payload, emits, block}
  end

  # Parse server_events block to extract {name, payload} tuples
  defp extract_server_events({:__block__, _, items}), do: Enum.map(items, &parse_server_event/1)
  defp extract_server_events(single), do: [parse_server_event(single)]

  defp parse_server_event({:event, _, [name, opts]}) do
    payload = Keyword.fetch!(opts, :payload)
    {name, payload}
  end

  # Generate an Ash action definition for a client event
  defp generate_client_action({name, payload, _emits, handler_block}) do
    arguments = generate_arguments(payload)
    bindings = generate_bindings(payload)

    quote do
      action unquote(name), :map do
        unquote_splicing(arguments)

        run fn input, _context ->
          unquote_splicing(bindings)
          unquote(handler_block)
        end
      end
    end
  end

  # Generate `argument` calls from payload spec
  defp generate_arguments({:%{}, _, fields}) do
    Enum.map(fields, fn {field_name, type} ->
      quote do
        argument unquote(field_name), unquote(type)
      end
    end)
  end

  defp generate_arguments(_), do: []

  # Generate variable bindings from input.arguments
  defp generate_bindings({:%{}, _, fields}) do
    Enum.map(fields, fn {field_name, _type} ->
      quote do
        unquote(Macro.var(field_name, nil)) = input.arguments[unquote(field_name)]
      end
    end)
  end

  defp generate_bindings(_), do: []

  defmacro __before_compile__(_env) do
    quote do
      @doc "Returns all client events as {name, payload, emits} tuples"
      def __client_events__, do: @reify_studio_client_events |> Enum.reverse()

      @doc "Returns all server events as {name, payload} tuples"
      def __server_events__, do: @reify_studio_server_events |> Enum.reverse()

      def client_event_names, do: __client_events__() |> Enum.map(&elem(&1, 0))
      def server_event_names, do: __server_events__() |> Enum.map(&elem(&1, 0))

      @doc "Get the server event to emit for a client event (if specified)"
      def success_event(client_event) when is_atom(client_event) do
        case Enum.find(__client_events__(), fn {name, _, _} -> name == client_event end) do
          {_, _, emits} -> emits
          nil -> nil
        end
      end

      def success_event(client_event) when is_binary(client_event) do
        success_event(String.to_existing_atom(client_event))
      rescue
        ArgumentError -> nil
      end

      def client_event?(name) when is_atom(name), do: name in client_event_names()

      def client_event?(name) when is_binary(name) do
        String.to_existing_atom(name) in client_event_names()
      rescue
        ArgumentError -> false
      end

      def server_event?(name) when is_atom(name), do: name in server_event_names()

      def server_event?(name) when is_binary(name) do
        String.to_existing_atom(name) in server_event_names()
      rescue
        ArgumentError -> false
      end
    end
  end
end
