defmodule StreamPipe.Mixfile do
  use Mix.Project

  def project do
    [
      app: :stream_pipe,
      version: "0.0.6",
      elixir: "~> 1.1",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps,
      deps_path: "../../deps",
      lockfile: "../../mix.lock"
    ]
  end

  def application do
    [
      applications: [:logger, :chatter, :group_manager],
      mod: {StreamPipe, []}
    ]
  end

  defp deps do
    [
      {:chatter, "~> 0.0.10"},
      {:group_manager, path: "../../apps/group_manager"}
    ]
  end
end
