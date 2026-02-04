# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# This is a good place to put seed data that should exist for demos.

alias ReifyStudioStudioStudio.Demos.Todos
alias ReifyStudioStudioStudio.Demos.Todos.Todo

# Clear existing todos
ReifyStudioStudioStudio.Repo.delete_all(Todo)

# Create seed todos
seed_todos = [
  %{title: "Learn Ash", completed: true},
  %{title: "Build demo", completed: false},
  %{title: "Ship it", completed: false}
]

for attrs <- seed_todos do
  {:ok, todo} = Todos.create_todo(attrs.title)

  if attrs.completed do
    Todos.toggle_todo(todo)
  end
end

IO.puts("Seeded #{length(seed_todos)} todos")
