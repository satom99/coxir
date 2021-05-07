defmodule Example.MixProject do
  use Mix.Project

  def project do
    [
      app: :example,
      version: "0.1.0",
      elixir: "~> 1.11",
      deps_path: "../deps",
      build_path: "../_build",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Example, []}
    ]
  end

  defp deps do
    [
      {:coxir, path: "../"}
    ]
  end
end
