defmodule GroupManager.Mixfile do
  use Mix.Project

  def project do
    [
      app: :group_manager,
      version: "0.0.1",
      elixir: "~> 1.0",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps,
      deps_path: "../../deps",
      lockfile: "../../mix.lock"
      # test_coverage: [tool: ExCoveralls]
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
      # {:lz4, "~> 0.2.2"},
      {:fsm, "~> 0.2.0"},
      {:exactor, "~> 2.2"},
      {:ranch, "~> 1.2"}
    ]
  end
end
