defmodule Coxir.MixProject do
  use Mix.Project

  def project do
    [
      app: :coxir,
      version: "0.1.0",
      elixir: "~> 1.10",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp deps do
    [
      {:ecto, "~> 3.4"}
    ]
  end
end
