defmodule GroupManager.Mixfile do
  use Mix.Project

  def project do
    [app: :group_manager,
     version: "0.0.1",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     deps_path: "../../deps",
     lockfile: "../../mix.lock"
   ]
  end

  def application do
    [applications: [:logger, :xxhash],
     mod: {GroupManager, []}]
  end

  defp deps do
    [
      {:xxhash, git: "https://github.com/pierresforge/erlang-xxhash"},
      {:fsm, "~> 0.2.0"},
      {:exactor, "~> 2.2"},
      {:excheck, "~> 0.3", only: :test},
      {:triq, github: "krestenkrab/triq", only: :test}
    ]
  end
end
