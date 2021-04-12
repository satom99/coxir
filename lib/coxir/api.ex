defmodule Coxir.API do
  @moduledoc false

  use Tesla, only: []

  adapter(Tesla.Adapter.Gun)

  plug(Tesla.Middleware.JSON)

  plug(Tesla.Middleware.BaseUrl, "https://discord.com/api")

  plug(Tesla.Middleware.Headers, [{"User-Agent", "coxir"}])

  plug(Tesla.Middleware.PathParams)

  plug(Tesla.Middleware.KeepRequest)
end
