defmodule StreamPipe.Mixfile do
  use Mix.Project

  def project do
    [
      app: :stream_pipe,
      version: "0.0.7",
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
      {:xxhash, git: "https://github.com/pierresforge/erlang-xxhash"},
      {:chatter, "~> 0.0.12"},
      {:group_manager, "~> 0.0.7"}
    ]
  end
end
