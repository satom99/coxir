defmodule Coxir.MixProject do
  use Mix.Project

  def project do
    [
      app: :coxir,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs()
    ]
  end

  def application do
    [
      mod: {Coxir, []}
    ]
  end

  defp deps do
    [
      {:ecto, "~> 3.6"},
      {:idna, "~> 6.1"},
      {:castore, "~> 0.1.9"},
      {:jason, "~> 1.2"},
      {:gun, "~> 1.3"},
      {:tesla, "~> 1.4"},
      {:ex_doc, "~> 0.24.2", only: :dev}
    ]
  end

  defp docs do
    [
      groups_for_modules: [
        Entities: [
          Coxir.User,
          Coxir.Guild,
          Coxir.Channel,
          Coxir.Message
        ],
        Model: ~r/Coxir.Model.?/,
        Storage: ~r/^Coxir.Storage.?/,
        Limiter: ~r/^Coxir.Limiter.?/,
        Gateway: [
          ~r/^Coxir.Gateway.?/,
          Coxir.Consumer,
          Coxir.Sharder
        ],
        API: ~r/^Coxir.API.?/,
        Helpers: [
          Coxir.Token
        ]
      ],
      nest_modules_by_prefix: [
        Coxir.Model,
        Coxir.Storage,
        Coxir.Limiter,
        Coxir.Gateway,
        Coxir.API
      ]
    ]
  end
end
