defmodule AgentFirehose.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AgentFirehose.Listener
    ]

    opts = [strategy: :one_for_one, name: AgentFirehose.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
