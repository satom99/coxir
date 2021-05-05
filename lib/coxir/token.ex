defmodule Coxir.Token do
  @moduledoc """
  Work in progress.
  """
  alias Coxir.Model.Snowflake

  @type t :: String.t()

  @spec get_user_id(t) :: Snowflake.t()
  def get_user_id(token) do
    {:ok, user_id} =
      token
      |> String.split(".")
      |> List.first()
      |> Base.decode64!()
      |> Snowflake.cast()

    user_id
  end
end
