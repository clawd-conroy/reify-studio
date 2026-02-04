defmodule ReifyStudio.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ReifyStudioWeb.Telemetry,
      ReifyStudio.Repo,
      {DNSCluster, query: Application.get_env(:reify_studio, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ReifyStudio.PubSub},
      # OpenClaw Gateway WebSocket client
      {ReifyStudio.OpenClaw.GatewayClient, openclaw_config()},
      # Start to serve requests, typically the last entry
      ReifyStudioWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ReifyStudio.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  defp openclaw_config do
    config = Application.get_env(:reify_studio, :openclaw, [])
    url = Keyword.get(config, :gateway_url, "ws://127.0.0.1:18789")
    token = Keyword.get(config, :gateway_token)
    [url: url, token: token]
  end

  @impl true
  def config_change(changed, _new, removed) do
    ReifyStudioWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
