defmodule Reify.Demos.Todos.Todo do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    domain: Reify.Demos.Todos,
    extensions: [AshJason.Resource, AshTypescript.Resource]

  postgres do
    repo Reify.Repo
    table "todos"
  end

  typescript do
    type_name "Todo"
  end

  actions do
    create :create do
      accept [:title]
    end

    defaults [:read, :destroy]

    read :list do
      prepare build(sort: [inserted_at: :asc])
    end

    update :toggle_complete do
      require_atomic? true

      change atomic_update(:completed, expr(not (^atomic_ref(:completed))))
    end

    update :update_title do
      accept [:title]
    end
  end

  validations do
    validate present(:title) do
      message "Title cannot be empty"
    end

    validate string_length(:title, max: 100) do
      message "Title cannot be longer than 100 characters"
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :completed, :boolean do
      allow_nil? false
      default false
      public? true
    end

    attribute :title, :string do
      allow_nil? false
      public? true
    end

    timestamps()
  end

  identities do
    identity :unique_title, [:title], message: "A todo with this title already exists"
  end
end
