defmodule Coxir.Snowflake do
  @moduledoc """
  Work in progress.
  """
  use Ecto.Type

  @type t :: integer

  defguard is_snowflake(value) when is_integer(value) and value in 0..0xFFFFFFFFFFFFFFFF

  def type do
    :string
  end

  def cast(value) when is_binary(value) do
    case Integer.parse(value) do
      {integer, ""} ->
        cast(integer)

      _other ->
        :error
    end
  end

  def cast(value) when is_snowflake(value) do
    {:ok, value}
  end

  def cast(_value) do
    :error
  end

  def load(value) do
    cast(value)
  end

  def dump(value) when is_snowflake(value) do
    {:ok, to_string(value)}
  end

  def dump(_value) do
    :error
  end
end
