defmodule Reify.Demos.Todos.Events do
  @moduledoc """
  Bidirectional events for the Todos domain.

  Defines:
  - Client events: what the client can send via pushEvent
  - Server events: what the client can listen for via handleEvent
  """

  use Ash.Resource,
    domain: Reify.Demos.Todos,
    extensions: [AshTypescript.Resource]

  use Reify.EventsDsl

  alias Reify.Demos.Todos

  typescript do
    type_name "TodoEvents"
  end

  resource do
    require_primary_key? false
  end

  # Events the client can send to the server
  client_events do
    event :create_todo, payload: %{title: :string}, emits: :todo_created do
      Todos.create_todo(title)
    end

    event :toggle_todo, payload: %{todo_id: :uuid}, emits: :todo_toggled do
      with {:ok, todo} <- Todos.get_todo(todo_id) do
        Todos.toggle_todo(todo)
      end
    end

    event :update_title, payload: %{todo_id: :uuid, title: :string}, emits: :title_updated do
      with {:ok, todo} <- Todos.get_todo(todo_id) do
        Todos.update_todo_title(todo, title)
      end
    end

    event :delete_todo, payload: %{todo_id: :uuid}, emits: :todo_deleted do
      with {:ok, todo} <- Todos.get_todo(todo_id),
           :ok <- Todos.delete_todo(todo) do
        {:ok, %{id: todo_id, deleted: true}}
      end
    end
  end

  # Events the server can send to the client
  server_events do
    event(:todo_created, payload: Todos.Todo)
    event(:todo_toggled, payload: Todos.Todo)
    event(:title_updated, payload: Todos.Todo)
    event(:todo_deleted, payload: %{id: :uuid, deleted: :boolean})
    event(:error, payload: %{source: :string, code: :string, message: :string})
  end
end
