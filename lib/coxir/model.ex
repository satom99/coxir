defmodule Coxir.Model do
  @moduledoc """
  Work in progress.
  """
  alias Coxir.Model.{Snowflake, Loader}
  alias Coxir.API

  @type model :: module

  @type instance :: struct

  @type key :: Snowflake.t() | tuple

  @callback fetch(key, Loader.options()) :: API.result() | {:error, 404, nil}

  @callback fetch_many(key, atom, Loader.options()) :: API.result()

  @callback insert(map, Loader.options()) :: API.result()

  @callback patch(key, map, Loader.options()) :: API.result()

  @callback drop(key, Loader.options()) :: API.result()

  @callback get(key, Loader.options()) :: instance | nil

  @callback preload(instance, atom, Loader.options()) :: instance

  @callback create(Enum.t(), Loader.options()) :: Loader.result()

  @callback update(instance, Enum.t(), Loader.options()) :: Loader.result()

  @callback delete(instance, Loader.options()) :: Loader.result()

  @optional_callbacks [fetch: 2, fetch_many: 3, insert: 2, patch: 3, drop: 2, preload: 3]

  defmacro __using__(options \\ []) do
    embed? = Keyword.get(options, :embed?, false)

    quote location: :keep do
      use Ecto.Schema

      alias Coxir.API
      alias Coxir.Model.{Snowflake, Loader}
      alias Coxir.{User, Channel, Webhook, Message}
      alias Coxir.{Guild, Integration, Role}
      alias Coxir.{Member, Presence, VoiceState}

      @type t :: %__MODULE__{}

      if not unquote(embed?) do
        @primary_key {:id, Snowflake, []}
        @foreign_key_type Snowflake

        @behaviour Coxir.Model

        @doc false
        def fetch(_key, _options) do
          {:error, 404, nil}
        end

        @doc false
        def fetch_many(key, association, options)

        @doc false
        def insert(params, options)

        @doc false
        def patch(key, params, options)

        @doc false
        def drop(key, options)

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

        defoverridable(fetch: 2, preload: 3)
      end
    end
  end
end
