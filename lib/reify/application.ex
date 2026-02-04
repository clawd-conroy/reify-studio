defmodule Reify.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ReifyWeb.Telemetry,
      Reify.Repo,
      {DNSCluster, query: Application.get_env(:reify, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Reify.PubSub},
      # Start a worker by calling: Reify.Worker.start_link(arg)
      # {Reify.Worker, arg},
      # Start to serve requests, typically the last entry
      ReifyWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Reify.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ReifyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
