defmodule AgentFirehose.MixProject do
  use Mix.Project

  def project do
    [
      app: :agent_firehose,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {AgentFirehose.Application, []}
    ]
  end

  defp deps do
    [
      {:drinkup, "~> 0.2"},
      {:jason, "~> 1.4"}
    ]
  end
end
