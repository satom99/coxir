defmodule Coxir.API.Modeler do
  @moduledoc """
  Transforms responses into `t:Coxir.Model.t/0` and stores them.
  """
  @behaviour Tesla.Middleware

  def call(env, next, _options) do
    Tesla.run(env, next)
  end
end
