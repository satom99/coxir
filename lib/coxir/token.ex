defmodule Coxir.Token do
  @moduledoc """
  Work in progress.
  """
  alias Coxir.Model.Snowflake
  alias Coxir.API.Error
  alias Coxir.Gateway

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

  @spec from_options(Enum.t()) :: t | nil
  def from_options(options) when is_list(options) do
    options
    |> Map.new()
    |> from_options()
  end

  def from_options(%{as: gateway}) do
    Gateway.get_token(gateway)
  end

  def from_options(options) do
    config = Application.get_env(:coxir, :token)
    Map.get(options, :token, config)
  end

  @spec from_options!(Enum.t()) :: t
  def from_options!(options) do
    with nil <- from_options(options) do
      raise(Error, status: 401)
    end
  end
end
