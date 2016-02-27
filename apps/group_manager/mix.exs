defmodule GroupManager.Mixfile do
  use Mix.Project

  def project do
    [
      app: :group_manager,
      version: "0.0.6",
      elixir: "~> 1.0",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps,
      deps_path: "../../deps",
      lockfile: "../../mix.lock"
    ]
  end

  def application do
    [
      applications: [:logger, :xxhash, :ranch, :chatter],
      mod: {GroupManager, []}
    ]
  end

  defp deps do
    [
      {:chatter, path: "../../apps/chatter"},
      {:snappy, "~> 1.1"},
      {:xxhash, git: "https://github.com/pierresforge/erlang-xxhash"},
      {:exactor, "~> 2.2"},
      {:ranch, "~> 1.2"}
    ]
  end
end
