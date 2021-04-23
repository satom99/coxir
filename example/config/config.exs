import Config

config :coxir,
  storage: Coxir.Storage.Default,
  limiter: Coxir.Limiter.Default,
  sharder: Coxir.Gateway.Sharder.Default,
  shard_count: 1,
  intents: :non_privileged,
  token: ""
