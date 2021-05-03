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
      {:ecto, "~> 3.6"},
      {:idna, "~> 6.1"},
      {:castore, "~> 0.1.9"},
      {:jason, "~> 1.2"},
      {:gun, "~> 1.3"},
      {:tesla, "~> 1.4"},
      {:gen_stage, "~> 1.1"},
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
          ~r/^Coxir.Sharder.?/
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
      main: "Introduction"
    ]
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/satom99/coxir2"}
    ]
  end
end
