defmodule Coxir.Model do
  @moduledoc """
  Work in progress.
  """
  alias Coxir.Model.Snowflake

  @type model :: module

  @type instance :: struct

  @type key :: Snowflake.t() | tuple

  @callback fetch(key, keyword) :: instance | nil

  @callback fetch_association(instance, atom, keyword) :: instance | nil | list(instance) | list

  @optional_callbacks [fetch_association: 3]

  defmacro __using__(_options) do
    quote location: :keep do
      use Ecto.Schema

      alias Coxir.API
      alias Coxir.Model.{Snowflake, Loader}
      alias Coxir.{User, Guild, Channel, Message}

      @behaviour Coxir.Model

      @primary_key {:id, Snowflake, []}
      @foreign_key_type Snowflake
    end
  end
end
