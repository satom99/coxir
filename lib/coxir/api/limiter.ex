defmodule Coxir.API.Limiter do
  @moduledoc """
  Work in progress.
  """
  @behaviour Tesla.Middleware

  def call(env, next, _options) do
    Tesla.run(env, next)
  end
end
