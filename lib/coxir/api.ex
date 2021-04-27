defmodule Coxir.API do
  @moduledoc """
  Work in progress.
  """
  use Tesla, only: [], docs: false

  alias Coxir.API.Error

  @type method :: Tesla.Env.method()

  @type path :: Tesla.Env.url()

  @type options :: Tesla.Env.opts()

  @type body :: Tesla.Env.body()

  @type status :: Tesla.Env.status()

  @type result :: :ok | {:ok, body} | {:error, status, Error.t()}

  adapter(Tesla.Adapter.Gun)

  plug(Tesla.Middleware.Retry)

  plug(Tesla.Middleware.JSON)

  plug(Tesla.Middleware.BaseUrl, "https://discord.com/api")

  plug(Coxir.API.Headers)

  plug(Coxir.API.RateLimiter)

  @spec perform(method, path, options, body) :: result
  def perform(method, path, options \\ [], body \\ nil) do
    options = Keyword.new(options)

    case request!(method: method, url: path, opts: options, body: body) do
      %{status: 204} ->
        :ok

      %{status: status, body: body} when status in [200, 201, 304] ->
        {:ok, body}

      %{status: status, body: body} ->
        error = Error.cast(body)
        {:error, status, error}
    end
  end

  def get(path, options) do
    perform(:get, path, options)
  end

  def post(path, body, options) do
    perform(:post, path, options, body)
  end

  def patch(path, body, options) do
    perform(:patch, path, options, body)
  end
end
