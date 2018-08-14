defmodule Cox.Mixfile do
  use Mix.Project

  def project do
    [
      app: :welcome,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      build_permanent: Mix.env == :prod,
      deps: [
        {:coxir, git: "https://github.com/satom99/coxir.git"},
        {:coxir_commander, git: "https://github.com/satom99/coxir_commander.git"},
        {:httpotion, "~> 3.1.0"},
        {:ex_doc, "~> 0.18.0", only: :dev, runtime: false}
      ]
    ]
  end

  def application do
    [
      mod: {Welcome, []}
    ]
  end
end
