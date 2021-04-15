defmodule Coxir.Model.Snowflake do
  @moduledoc """
  Work in progress.
  """
  use Ecto.Type

  @type t :: integer

  defguard is_snowflake(term) when is_integer(term) and term in 0..0xFFFFFFFFFFFFFFFF

  def type do
    :integer
  end

  def cast(integer) when is_snowflake(integer) do
    {:ok, integer}
  end

  def cast(string) when is_binary(string) do
    case Integer.parse(string) do
      {integer, ""} ->
        cast(integer)

      _other ->
        :error
    end
  end

  def cast(_term) do
    :error
  end

  def load(term) do
    cast(term)
  end

  def dump(integer) when is_snowflake(integer) do
    {:ok, integer}
  end

  def dump(_term) do
    :error
  end
end
