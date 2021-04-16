defmodule Coxir.API do
  @moduledoc """
  Work in progress.
  """
  use Tesla, only: [], docs: false

  @type method :: :get

  @type path :: binary

  @type options :: keyword

  @type body :: nil | map

  @type status :: non_neg_integer

  @type result :: :ok | {:ok, body} | {:error, status}

  adapter(Tesla.Adapter.Gun)

  plug(Tesla.Middleware.JSON)

  plug(Tesla.Middleware.BaseUrl, "https://discord.com/api")

  plug(Tesla.Middleware.Headers, [{"User-Agent", "coxir"}])

  plug(Coxir.API.Authorization)

  plug(Coxir.API.RateLimiter)

  plug(Tesla.Middleware.KeepRequest)

  @spec execute(method, path, options, body) :: result
  def execute(method, path, options \\ [], body \\ nil) do
    case request!(method: method, url: path, body: body, opts: options) do
      %{status: 204} ->
        :ok

      %{status: status, body: body} when status in [200, 201, 304] ->
        {:ok, body}

      %{status: status} ->
        {:error, status}
    end
  end

  def get(path, options) do
    execute(:get, path, options)
  end
end
