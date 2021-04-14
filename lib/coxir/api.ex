defmodule Coxir.API do
  @moduledoc """
  Work in progress.
  """
  use Tesla, only: []

  adapter(Tesla.Adapter.Gun)

  plug(Tesla.Middleware.JSON)

  plug(Tesla.Middleware.PathParams)

  plug(Tesla.Middleware.BaseUrl, "https://discord.com/api")

  plug(Tesla.Middleware.Headers, [{"User-Agent", "coxir"}])

  plug(Coxir.API.Token)

  plug(Coxir.API.Limiter)

  plug(Tesla.Middleware.KeepRequest)
end
