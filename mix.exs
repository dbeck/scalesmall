defmodule ScaleSmall.Mixfile do
  use Mix.Project

  def project do
    [app: :scalesmall,
     version: "0.0.1",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger, :ranch],
     mod: {ScaleSmall, []}]
  end

  defp deps do
    [{:ranch, "~> 1.1"}]
  end
end
