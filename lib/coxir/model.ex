defmodule Coxir.Model do
  @moduledoc """
  Work in progress.
  """
  alias Coxir.Model.Snowflake

  @type name :: module

  @type object :: struct

  @callback fetch(Snowflake.t(), Keyword.t()) :: object

  defmacro __using__(_options) do
    quote location: :keep do
      use Ecto.Schema

      alias Coxir.Model.Snowflake
      alias Coxir.{User, Guild, Channel, Message}
      alias Coxir.API

      @behaviour Coxir.Model

      @primary_key {:id, Snowflake, []}
      @foreign_key_type Snowflake
    end
  end
end
