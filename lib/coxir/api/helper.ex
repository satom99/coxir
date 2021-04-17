defmodule Coxir.API.Helper do
  @moduledoc """
  Common helper functions for `Coxir.API` middlewares.
  """
  alias Coxir.Token

  @spec get_token(Tesla.Env.t()) :: Token.t()
  def get_token(%{opts: options}) do
    config = Application.get_env(:coxir, :token)
    Keyword.get(options, :token, config)
  end
end
