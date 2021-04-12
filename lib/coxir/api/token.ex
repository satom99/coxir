defmodule Coxir.API.Token do
  @moduledoc """
  Work in progress.
  """
  @behaviour Tesla.Middleware

  alias Tesla.Middleware.Headers

  def call(%{opts: opts} = env, next, _options) do
    config = Application.get_env(:coxir, :token)
    token = Keyword.get(opts, :token, config)

    headers = [{"Authorization", "Bot #{token}"}]

    Headers.call(env, next, headers)
  end
end
