defmodule Coxir.Struct do
  @moduledoc """
  Work in progress.
  """
  @type t :: struct

  defmacro __using__(_options) do
    quote location: :keep do
      use Ecto.Schema

      import Ecto.Changeset

      alias Coxir.Snowflake
      alias Coxir.{User, Guild, Channel}

      @primary_key {:id, Snowflake, []}
      @foreign_key_type Snowflake

      def changeset(params) do
        __MODULE__
        |> struct
        |> changeset(params)
      end

      def changeset(struct, params) do
        fields = __schema__(:fields)
        changeset = cast(struct, params, fields)

        associations = __schema__(:associations)

        Enum.reduce(
          associations,
          changeset,
          fn name, changeset ->
            cast_assoc(changeset, name)
          end
        )
      end

      defoverridable changeset: 2
    end
  end
end
