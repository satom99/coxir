defmodule Coxir.Model do
  @moduledoc """
  Work in progress.
  """
  alias Coxir.Model.Snowflake

  @type model :: module

  @type instance :: struct

  @type key :: Snowflake.t() | tuple

  @callback fetch(key, keyword) :: instance | nil

  @callback preload(instance, atom, keyword) :: instance

  @callback fetch_many(key, atom, keyword) :: list(instance)

  @optional_callbacks [fetch: 2, preload: 3, fetch_many: 3]

  defmacro __using__(_options) do
    quote location: :keep do
      use Ecto.Schema

      alias Coxir.API
      alias Coxir.Model.{Snowflake, Loader}
      alias Coxir.{User, Channel, Webhook, Message}
      alias Coxir.{Guild, Integration, Role, Member}

      @behaviour Coxir.Model

      @primary_key {:id, Snowflake, []}
      @foreign_key_type Snowflake

      @type t :: %__MODULE__{}

      def get(key, options \\ []) do
        Loader.get(__MODULE__, key, options)
      end

      def preload(struct, association, options \\ []) do
        Loader.preload(struct, association, options)
      end

      defoverridable(preload: 3)
    end
  end
end
