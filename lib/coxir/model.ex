defmodule Coxir.Model do
  @moduledoc """
  Work in progress.
  """
  alias Coxir.Storage

  @type name :: module

  @type object :: struct

  @callback fetch(Storage.key(), Keyword.t()) :: object :: nil

  defmacro __using__(_options) do
    quote location: :keep do
      @behaviour Coxir.Model

      use Ecto.Schema

      alias Coxir.Model.{Snowflake, Loader}
      alias Coxir.{User, Guild, Channel, Message}
      alias Coxir.API

      @primary_key {:id, Snowflake, []}
      @foreign_key_type Snowflake
    end
  end
end
