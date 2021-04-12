defmodule Coxir.API.Limiter do
  @moduledoc """
  Responsible for handling ratelimits.
  """
  @behaviour Tesla.Middleware

  def call(env, next, _options) do
    Tesla.run(env, next)
  end
end
