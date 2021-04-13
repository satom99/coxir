defmodule Coxir.API do
  @moduledoc false

  use Tesla, only: []

  adapter(Tesla.Adapter.Gun)

  plug(Tesla.Middleware.JSON)

  plug(Tesla.Middleware.BaseUrl, "https://discord.com/api")

  plug(Tesla.Middleware.Headers, [{"User-Agent", "coxir"}])

  plug(Coxir.API.Token)

  plug(Coxir.API.Limiter)

  plug(Coxir.API.Modeler)

  plug(Tesla.Middleware.PathParams)

  plug(Tesla.Middleware.KeepRequest)

  plug(Tesla.Middleware.Logger, debug: false)
end
