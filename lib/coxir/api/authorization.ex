defmodule Coxir.API.Authorization do
  @moduledoc """
  Introduces the `Authorization` request header.
  """
  @behaviour Tesla.Middleware

  import Coxir.API.Helper

  alias Tesla.Middleware.Headers

  def call(request, next, _options) do
    token = get_token(request)
    headers = [{"Authorization", "Bot #{token}"}]
    Headers.call(request, next, headers)
  end
end
