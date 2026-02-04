defmodule Reify.Demos.Todos do
  @moduledoc """
  Domain for todo management.
  Demonstrates Ash form validation pattern with PostgreSQL persistence.
  """
  use Ash.Domain, extensions: [AshTypescript.Rpc]

  # Generate TypeScript types
  typescript_rpc do
    # Todo type for responses
    resource Reify.Demos.Todos.Todo do
      rpc_action :list_todos, :list
      rpc_action :get_todo, :read, get_by: [:id]
    end

    # Event Commands - the public mutation API
    resource Reify.Demos.Todos.Events do
      rpc_action :create_todo, :create_todo
      rpc_action :toggle_todo, :toggle_todo
      rpc_action :update_title, :update_title
      rpc_action :delete_todo, :delete_todo
    end
  end

  resources do
    resource Reify.Demos.Todos.Todo do
      define :create_todo, action: :create, args: [:title]
      define :delete_todo, action: :destroy
      define :get_todo, action: :read, get_by: [:id]
      define :list_todos, action: :list
      define :toggle_todo, action: :toggle_complete
      define :update_todo_title, action: :update_title, args: [:title]
    end

    # Event Commands (no data layer, multiple actions)
    resource Reify.Demos.Todos.Events
  end
end
