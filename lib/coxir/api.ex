defmodule Coxir.API do
  @moduledoc """
  Entry-point to the Discord REST API.
  """
  use Tesla, only: [], docs: false

  alias Tesla.Env
  alias Coxir.{Gateway, Token}
  alias Coxir.API.Error

  @typedoc """
  The options that can be passed to `perform/4`.

  If the `:as` option is present, the token of the given gateway will be used.

  If no token is provided, one is expected to be configured as `:token` under the `:coxir` app.
  """
  @type options :: [
          token: Token.t() | none,
          as: Gateway.gateway() | none
        ]

  @typedoc """
  The possible outcomes of `perform/4`.
  """
  @type result :: :ok | {:ok, map} | {:error, Error.t()}

  adapter(Tesla.Adapter.Gun)

  plug(Coxir.API.Headers)

  plug(Tesla.Middleware.BaseUrl, "https://discord.com/api/v9")

  plug(Tesla.Middleware.JSON)

  plug(Tesla.Middleware.Retry)

  plug(Coxir.API.RateLimiter)

  @doc """
  Performs a request to the API.
  """
  @spec perform(Env.method(), Env.url(), Env.body(), options) :: result
  def perform(method, path, body \\ nil, options) do
    options = Keyword.new(options)

    case request!(method: method, url: path, body: body, opts: options) do
      %{status: 204} ->
        :ok

      %{status: status, body: body} when status in [200, 201, 304] ->
        {:ok, body}

      %{status: status, body: body} ->
        error = Error.cast(status, body)
        {:error, error}
    end
  end

  @doc """
  Delegates to `perform/4` with `method` set to `:get`.
  """
  @spec get(Env.url(), options) :: result
  def get(path, options) do
    perform(:get, path, options)
  end

  @doc """
  Delegates to `perform/4` with `method` set to `:post`.
  """
  @spec post(Env.url(), Env.body(), options) :: result
  def post(path, body \\ %{}, options) do
    perform(:post, path, body, options)
  end

  @doc """
  Delegates to `perform/4` with `method` set to `:put`.
  """
  @spec put(Env.url(), Env.body(), options) :: result
  def put(path, body \\ %{}, options) do
    perform(:put, path, body, options)
  end

  @doc """
  Delegates to `perform/4` with `method` set to `:patch`.
  """
  @spec patch(Env.url(), Env.body(), options) :: result
  def patch(path, body, options) do
    perform(:patch, path, body, options)
  end

  @doc """
  Delegates to `perform/4` with `method` set to `:delete`.
  """
  @spec delete(Env.url(), options) :: result
  def delete(path, options) do
    perform(:delete, path, options)
  end
end
