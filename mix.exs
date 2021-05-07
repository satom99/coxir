defmodule Coxir.MixProject do
  use Mix.Project

  def project do
    [
      app: :coxir,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package(),
      source_url: "https://github.com/satom99/coxir2"
    ]
  end

  def application do
    [
      mod: {Coxir, []}
    ]
  end

  defp deps do
    [
      {:ecto, ">= 3.0.0"},
      {:jason, ">= 1.0.0"},
      {:idna, ">= 6.0.0"},
      {:castore, ">= 0.1.0"},
      {:gun, ">= 1.3.0"},
      {:tesla, ">= 1.3.0"},
      {:gen_stage, ">= 0.14.0"},
      {:kcl, ">= 1.0.0"},
      {:ex_doc, "~> 0.24.2", only: :dev}
    ]
  end

  defp docs do
    [
      groups_for_modules: [
        Entities: [
          Coxir.User,
          Coxir.Channel,
          Coxir.Overwrite,
          Coxir.Webhook,
          ~r/^Coxir.Message.?/,
          ~r/^Coxir.Interaction.?/,
          Coxir.Guild,
          Coxir.Integration,
          Coxir.Role,
          Coxir.Member,
          ~r/^Coxir.Presence.?/,
          Coxir.VoiceState
        ],
        Adapters: [
          ~r/^Coxir.Limiter.?/,
          ~r/^Coxir.Storage.?/,
          ~r/^Coxir.Sharder.?/,
          ~r/^Coxir.Player.?/
        ],
        Model: [
          ~r/^Coxir.Model.?/
        ],
        API: [
          ~r/^Coxir.API.?/
        ],
        Gateway: [
          ~r/^Coxir.Gateway.?/,
          ~r/^Coxir.Payload.?/
        ],
        Voice: [
          ~r/^Coxir.Voice.?/
        ],
        Other: ~r/(.*?)/
      ],
      extra_section: "GUIDES",
      extras: [
        "guides/Introduction.md"
      ],
      main: "introduction"
    ]
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/satom99/coxir2"}
    ]
  end
end
