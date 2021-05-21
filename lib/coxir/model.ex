defmodule Coxir.Model do
  @moduledoc """
  The base behaviour for entities.
  """
  alias Macro.Env
  alias Coxir.API
  alias Coxir.API.Error
  alias Coxir.Model.{Snowflake, Loader}

  @typedoc """
  A module that implements the behaviour.
  """
  @type model :: module

  @typedoc """
  A struct object of a given `t:model/0`.
  """
  @type instance :: struct

  @typedoc """
  The internal coxir identificator for a `t:instance/0`.

  Matches the primary key of the `t:model/0`.

  If the primary key has many fields, they appear in the order they are defined.
  """
  @type key :: Snowflake.t() | tuple

  @doc """
  Called to fetch a `t:instance/0` from the API.
  """
  @callback fetch(key, keyword) :: API.result()

  @doc """
  Called to fetch a `Ecto.Schema.has_many/3` association of a `t:instance/0` from the API.
  """
  @callback fetch_many(key, atom, keyword) :: API.result()

  @doc """
  Called to create a `t:instance/0` through the API.
  """
  @callback insert(map, keyword) :: API.result()

  @doc """
  Called to update a `t:instance/0` through the API.
  """
  @callback patch(key, map, keyword) :: API.result()

  @doc """
  Called to delete a `t:instance/0` through the API.
  """
  @callback drop(key, keyword) :: API.result()

  @doc """
  Returns whether a `t:model/0` is hardcoded to be stored.
  """
  @callback storable?() :: boolean

  @doc """
  Delegates to `Coxir.Model.Loader.get/3`.
  """
  @callback get(key, Loader.options()) :: instance | Error.t()

  @doc """
  Delegates to `Coxir.Model.Loader.get!/3`.
  """
  @callback get!(key, Loader.options()) :: instance

  @doc """
  Delegates to `Coxir.Model.Loader.preload/3`.
  """
  @callback preload(instance, Loader.preloads(), Loader.options()) :: instance

  @callback preload(list(instance), Loader.preloads(), Loader.options()) :: list(instance)

  @doc """
  Delegates to `Coxir.Model.Loader.preload!/3`.
  """
  @callback preload!(instance, Loader.preloads(), Loader.options()) :: instance

  @callback preload!(list(instance), Loader.preloads(), Loader.options()) :: list(instance)

  @doc """
  Delegates to `Coxir.Model.Loader.create/3`.
  """
  @callback create(Enum.t(), Loader.options()) :: Loader.result()

  @doc """
  Delegates to `Coxir.Model.Loader.update/3`.
  """
  @callback update(instance, Enum.t(), Loader.options()) :: Loader.result()

  @doc """
  Delegates to `Coxir.Model.Loader.delete/2`.
  """
  @callback delete(instance, Loader.options()) :: Loader.result()

  @optional_callbacks [fetch: 2, fetch_many: 3, insert: 2, patch: 3, drop: 2, preload: 3]

  defmacro __using__(options \\ []) do
    storable? = Keyword.get(options, :storable?, true)

    quote location: :keep do
      use Ecto.Schema

      alias Coxir.API
      alias Coxir.API.Error
      alias Coxir.Model.{Snowflake, Loader}
      alias Coxir.{User, Channel, Invite, Overwrite, Webhook, Message, Interaction}
      alias Coxir.{Guild, Integration, Role, Ban}
      alias Coxir.{Member, Presence, VoiceState}
      alias Ecto.Association.NotLoaded
      alias __MODULE__

      @storable unquote(storable?)

      @before_compile Coxir.Model
      @behaviour Coxir.Model

      @primary_key {:id, Snowflake, []}
      @foreign_key_type Snowflake

      @doc false
      def storable?, do: @storable

      def get(key, options \\ []) do
        Loader.get(__MODULE__, key, options)
      end

      def get!(key, options \\ []) do
        Loader.get!(__MODULE__, key, options)
      end

      def preload(struct, preloads, options \\ []) do
        Loader.preload(struct, preloads, options)
      end

      def preload!(struct, preloads, options \\ []) do
        Loader.preload!(struct, preloads, options)
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

    ecto_assocs = Module.get_attribute(model, :ecto_assocs)
    preload? = length(ecto_assocs) > 0

    get = (storable? or fetch?) && nil
    preload = preload? && nil
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

      @doc unquote(get)
      def get!(key, options)

      @doc unquote(preload)
      def preload(struct, preloads, options)

      @doc unquote(preload)
      def preload!(struct, preloads, options)

      @doc unquote(create)
      def create(params, options)

      @doc unquote(update)
      def update(struct, params, options)

      @doc unquote(delete)
      def delete(struct, options)
    end
  end
end
