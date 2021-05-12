import Config

config :porcelain, driver: Porcelain.Driver.Basic

config :coxir,
  token: "",
  intents: :non_privileged
