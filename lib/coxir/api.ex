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

  plug(Tesla.Middleware.BaseUrl, "https://discord.com/api/v9")

  plug(Coxir.API.Headers)

  plug(Coxir.API.RateLimiter)

  @spec perform(method, path, options, body) :: result
  def perform(method, path, body, options) do
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
    perform(:get, path, nil, options)
  end

  def post(path, body, options) do
    perform(:post, path, body, options)
  end

  def patch(path, body, options) do
    perform(:patch, path, body, options)
  end

  def put(path, body, options) do
    perform(:put, path, body, options)
  end

  def delete(path, options) do
    perform(:delete, path, nil, options)
  end
end
