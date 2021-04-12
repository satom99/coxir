defmodule Coxir.API.Base do
  @moduledoc false

  use Tesla

  adapter(Tesla.Adapter.Gun)

  plug(Tesla.Middleware.JSON)

  plug(Tesla.Middleware.BaseUrl, "https://discord.com/api")

  plug(Tesla.Middleware.Headers, [{"User-Agent", "coxir"}])

  plug(Tesla.Middleware.PathParams)
end
