defmodule Mix.Tasks.ReifyStudio.Gen.EventsTs do
  @moduledoc """
  Generates TypeScript constants from EventsDsl modules.

  Usage:
    mix reify_studio.gen.events_ts

  This introspects modules using `ReifyStudio.EventsDsl` and generates
  TypeScript constants for client and server events.

  Output: assets/src/events.generated.ts
  """

  @shortdoc "Generate TypeScript event constants from EventsDsl"

  use Mix.Task

  @output_file "assets/src/events.generated.ts"

  def run(_args) do
    Mix.Task.run("compile")

    # Find all modules using EventsDsl
    events_modules = discover_events_modules()

    # Generate content for each module
    domains =
      Enum.map(events_modules, fn module ->
        client_events = module.__client_events__()
        server_events = module.__server_events__()

        # Derive prefix from module: ReifyStudio.Demos.Todos.Events -> "Todo"
        domain_name = module |> Module.split() |> Enum.at(-2) |> String.downcase()
        prefix = domain_name |> String.trim_trailing("s") |> String.capitalize()

        %{
          prefix: prefix,
          client_events: client_events,
          server_events: server_events
        }
      end)

    ts_content = generate_consolidated_typescript(domains)

    File.write!(@output_file, ts_content)
    Mix.shell().info("Generated #{@output_file}")
  end

  defp discover_events_modules do
    # For now, hardcode. Could use :application.get_key(:reify_studio, :modules) + filtering
    [ReifyStudio.Demos.Todos.Events]
  end

  defp generate_consolidated_typescript(domains) do
    # Collect all imports
    all_imports =
      domains
      |> Enum.flat_map(fn %{client_events: events} ->
        Enum.map(events, fn {name, _payload, _emits} -> to_input_type_name(name) end)
      end)
      |> Enum.join(", ")

    import_line =
      if all_imports != "" do
        "import type { #{all_imports} } from \"./ash_rpc\";\n"
      else
        ""
      end

    # Generate each domain's section
    domain_sections =
      domains
      |> Enum.map(&generate_domain_section/1)
      |> Enum.join("\n")

    """
    /**
     * Events - Auto-generated from Elixir EventsDsl.
     *
     * DO NOT EDIT MANUALLY - run `mix reify_studio.gen.events_ts` to regenerate.
     */

    #{import_line}
    #{domain_sections}
    """
  end

  defp generate_domain_section(%{
         prefix: prefix,
         client_events: client_events,
         server_events: server_events
       }) do
    client_const = generate_const(client_events)
    server_const = generate_const(server_events)
    payload_mapping = generate_payload_mapping(prefix, client_events)

    """
    // =============================================================================
    // #{prefix} Events
    // =============================================================================

    export const #{prefix}ClientEvents = {
    #{client_const}
    } as const;

    export type #{prefix}ClientEvent =
      (typeof #{prefix}ClientEvents)[keyof typeof #{prefix}ClientEvents];

    #{payload_mapping}

    export const #{prefix}ServerEvents = {
    #{server_const}
    } as const;

    export type #{prefix}ServerEvent =
      (typeof #{prefix}ServerEvents)[keyof typeof #{prefix}ServerEvents];
    """
  end

  defp generate_payload_mapping(prefix, client_events) do
    mapping_entries =
      client_events
      |> Enum.map(fn {name, _payload, _emits} ->
        type_name = to_input_type_name(name)
        "  \"#{name}\": #{type_name};"
      end)
      |> Enum.join("\n")

    """
    export type #{prefix}ClientEventPayloads = {
    #{mapping_entries}
    };
    """
  end

  defp generate_const(events) do
    events
    |> Enum.map(fn event ->
      event_name = elem(event, 0)
      const_name = event_name |> to_string() |> String.upcase()
      "  #{const_name}: \"#{event_name}\","
    end)
    |> Enum.join("\n")
  end

  # Convert snake_case event name to PascalCase input type name
  # create_todo -> CreateTodoInput
  defp to_input_type_name(event_name) do
    event_name
    |> to_string()
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join()
    |> Kernel.<>("Input")
  end
end
