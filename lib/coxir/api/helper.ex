defmodule Coxir.API.Helper do
  @moduledoc """
  Common helper functions for `Coxir.API` middlewares.
  """
  alias Coxir.Token

  @spec get_token(Tesla.Env.t()) :: Token.t()
  def get_token(%{opts: opts}) do
    config = Application.get_env(:coxir, :token)
    Keyword.get(opts, :token, config)
  end
end
