defmodule ReifyStudio.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """
  @app :reify_studio

  def migrate do
    load_app()

    for repo <- repos() do
      case Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true)) do
        {:ok, _, _} ->
          IO.puts("Migrations completed successfully for #{inspect(repo)}")

        {:error, reason} ->
          IO.puts("ERROR: Migration failed for #{inspect(repo)}: #{inspect(reason)}")
          System.halt(1)
      end
    end
  end

  def rollback(repo, version) do
    load_app()

    case Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version)) do
      {:ok, _, _} ->
        IO.puts("Rollback to #{version} completed successfully for #{inspect(repo)}")

      {:error, reason} ->
        IO.puts("ERROR: Rollback failed for #{inspect(repo)}: #{inspect(reason)}")
        System.halt(1)
    end
  end

  # credo:disable-for-lines:20 Credo.Check.Refactor.Nesting
  def seed do
    load_app()

    for repo <- repos() do
      case Ecto.Migrator.with_repo(repo, fn _repo ->
             seeds_path = Application.app_dir(@app, "priv/repo/seeds.exs")

             if File.exists?(seeds_path) do
               Code.eval_file(seeds_path)
               IO.puts("Seeds completed successfully for #{inspect(repo)}")
             else
               IO.puts("No seeds file found at #{seeds_path}")
             end
           end) do
        {:ok, _, _} ->
          :ok

        {:error, reason} ->
          IO.puts("ERROR: Seeding failed for #{inspect(repo)}: #{inspect(reason)}")
          System.halt(1)
      end
    end
  end

  def migrate_and_seed do
    migrate()
    seed()
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    # Many platforms require SSL when connecting to the database
    Application.ensure_all_started(:ssl)
    Application.ensure_loaded(@app)
  end
end
