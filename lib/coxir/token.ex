defmodule Coxir.Token do
  @moduledoc """
  Work in progress.
  """
  alias Coxir.Model.Snowflake

  @type t :: String.t()

  @spec get_snowflake(t) :: Snowflake.t()
  def get_snowflake(token) do
    {:ok, snowflake} =
      token
      |> String.split(".")
      |> Kernel.hd()
      |> Base.decode64!()
      |> Snowflake.cast()

    snowflake
  end
end
