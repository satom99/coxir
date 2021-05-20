defmodule Coxir.API.Helper do
  @moduledoc """
  Common helper functions for `Coxir.API` middlewares.
  """
  alias Tesla.Env
  alias Coxir.Token

  @spec get_token(Env.t()) :: Token.t()
  def get_token(%Env{opts: options}) do
    Token.from_options!(options)
  end
end
