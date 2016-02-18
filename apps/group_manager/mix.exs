defmodule GroupManager.Mixfile do
  use Mix.Project

  def project do
    [
      app: :group_manager,
      version: "0.0.4",
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
      applications: [:logger, :xxhash, :ranch],
      mod: {GroupManager, []}
    ]
  end

  defp deps do
    [
      {:xxhash, git: "https://github.com/pierresforge/erlang-xxhash"},
      {:snappy, "~> 1.1"},
      {:exactor, "~> 2.2"},
      {:ranch, "~> 1.2"}
    ]
  end
end
