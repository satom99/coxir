defmodule Coxir.Model do
  @moduledoc """
  Work in progress.
  """
  alias Macro.Env
  alias Coxir.API
  alias Coxir.Model.{Snowflake, Loader}

  @type model :: module

  @type instance :: struct

  @type key :: Snowflake.t() | tuple

  @callback fetch(key, keyword) :: API.result()

  @callback fetch_many(key, atom, keyword) :: API.result()

  @callback insert(map, keyword) :: API.result()

  @callback patch(key, map, keyword) :: API.result()

  @callback drop(key, keyword) :: API.result()

  @callback storable?() :: boolean

  @callback get(key, Loader.options()) :: instance | nil

  @callback preload(instance, Loader.preloads(), Loader.options()) :: instance

  @callback preload(list(instance), Loader.preloads(), Loader.options()) :: list(instance)

  @callback create(Enum.t(), Loader.options()) :: Loader.result()

  @callback update(instance, Enum.t(), Loader.options()) :: Loader.result()

  @callback delete(instance, Loader.options()) :: Loader.result()

  @optional_callbacks [fetch: 2, fetch_many: 3, insert: 2, patch: 3, drop: 2, preload: 3]

  defmacro __using__(options \\ []) do
    storable? = Keyword.get(options, :storable?, true)

    quote location: :keep do
      use Ecto.Schema

      alias Coxir.API
      alias Coxir.Model.{Snowflake, Loader}
      alias Coxir.{User, Channel, Overwrite, Webhook, Message}
      alias Coxir.{Guild, Integration, Role}
      alias Coxir.{Member, Presence, VoiceState}

      @storable unquote(storable?)

      @before_compile Coxir.Model
      @behaviour Coxir.Model

      @primary_key {:id, Snowflake, []}
      @foreign_key_type Snowflake

      @type t :: %__MODULE__{}

      @doc false
      def storable?, do: @storable

      def get(key, options \\ []) do
        Loader.get(__MODULE__, key, options)
      end

      def preload(struct, association, options \\ []) do
        Loader.preload(struct, association, options)
      end

      def create(params, options \\ []) do
        Loader.create(__MODULE__, params, options)
      end

      def update(struct, params, options \\ []) do
        Loader.update(struct, params, options)
      end

      def delete(struct, options \\ []) do
        Loader.delete(struct, options)
      end

      defoverridable(preload: 3)
    end
  end

  defmacro __before_compile__(%Env{module: model}) do
    storable? = Module.get_attribute(model, :storable)
    fetch? = Module.defines?(model, {:fetch, 2})
    insert? = Module.defines?(model, {:insert, 2})
    patch? = Module.defines?(model, {:patch, 3})
    drop? = Module.defines?(model, {:drop, 2})

    get = (storable? or fetch?) && nil
    create = insert? && nil
    update = patch? && nil
    delete = drop? && nil

    quote location: :keep do
      @doc false
      def fetch(key, options)

      @doc false
      def fetch_many(key, association, options)

      @doc false
      def insert(params, options)

      @doc false
      def patch(key, params, options)

      @doc false
      def drop(key, options)

      @doc unquote(get)
      def get(key, options)

      @doc unquote(create)
      def create(params, options)

      @doc unquote(update)
      def update(struct, params, options)

      @doc unquote(delete)
      def delete(struct, options)
    end
  end
end
