defmodule Scalesmall.Mixfile do
  use Mix.Project

  def project do
    [apps_path: "apps",
     version: "0.0.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  defp deps do
    []
  end
end
