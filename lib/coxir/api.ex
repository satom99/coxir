defmodule Coxir.API do
  @moduledoc """
  Work in progress.
  """
  use Tesla, only: [], docs: false

  adapter(Tesla.Adapter.Gun)

  plug(Tesla.Middleware.JSON)

  plug(Tesla.Middleware.BaseUrl, "https://discord.com/api")

  plug(Tesla.Middleware.Headers, [{"User-Agent", "coxir"}])

  plug(Coxir.API.Authorization)

  plug(Coxir.API.RateLimiter)

  plug(Tesla.Middleware.KeepRequest)

  def execute(method, path, body \\ nil, options \\ []) do
    response = request!(method: method, url: path, body: body, opts: options)
    response.body
  end

  def get(path, options) do
    execute(:get, path, nil, options)
  end
end
