defmodule Coxir.Model do
  @moduledoc """
  Work in progress.
  """
  @type name :: module

  @type object :: struct

  defmacro __using__(_options) do
    quote location: :keep do
      use Ecto.Schema

      alias Coxir.Model.{Snowflake, Loader}
      alias Coxir.{User, Guild, Channel, Message}
      alias Coxir.API

      @primary_key {:id, Snowflake, []}
      @foreign_key_type Snowflake
    end
  end
end
