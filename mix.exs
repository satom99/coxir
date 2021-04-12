defmodule Coxir.MixProject do
  use Mix.Project

  def project do
    [
      app: :coxir,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp deps do
    [
      {:ecto, "~> 3.6"},
      {:gun, "~> 1.3"},
      {:idna, "~> 6.1"},
      {:castore, "~> 0.1.9"},
      {:jason, "~> 1.2"},
      {:tesla, "~> 1.4"},
      {:ex_doc, "~> 0.24.2", only: :dev}
    ]
  end
end
