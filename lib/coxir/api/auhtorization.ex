defmodule Coxir.API.Auhtorization do
  @moduledoc """
  Introduces the `Authorization` request header.
  """
  @behaviour Tesla.Middleware

  alias Tesla.Middleware.Headers

  def call(request, next, _options) do
    token = get_token(request)
    headers = [{"Authorization", "Bot #{token}"}]
    Headers.call(request, next, headers)
  end

  def get_token(%{opts: opts}) do
    config = Application.get_env(:coxir, :token)
    Keyword.get(opts, :token, config)
  end
end
