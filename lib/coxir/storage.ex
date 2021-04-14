defmodule Coxir.Storage do
  @moduledoc """
  Work in progress.
  """
  import Ecto.Changeset

  alias Coxir.{Model, Snowflake}

  @callback child_spec(term) :: Supervisor.child_spec()

  @callback put(Model.t()) :: Model.t()

  @callback all(Model.t()) :: list(Model.t())

  @callback get(Model.t(), Snowflake.t()) :: Model.t() | nil

  @callback preload(Model.t(), Keyword.t()) :: Model.t()

  @callback delete(Model.t()) :: Model.t()

  @optional_callbacks [preload: 2]

  defmacro __using__(_options) do
    quote location: :keep do
      @behaviour Coxir.Storage

      import Coxir.Storage
    end
  end

  def child_spec(term) do
    storage().child_spec(term)
  end

  def put(struct) do
    storage().put(struct)
  end

  def all(model) do
    storage().all(model)
  end

  def get(model, primary) do
    storage().get(model, primary)
  end

  def preload(struct) do
    storage().preload(struct)
  end

  def delete(struct) do
    storage().delete(struct)
  end

  def merge(%model{} = base, %model{} = overwrite) do
    fields = get_fields(model)
    params = Map.take(overwrite, fields)

    base
    |> change(params)
    |> apply_changes
  end

  def get_fields(model) do
    fields = model.__schema__(:fields)
    primary = model.__schema__(:primary_key)
    primary ++ (fields -- primary)
  end

  def get_values(%model{} = struct) do
    Enum.map(
      get_fields(model),
      fn name ->
        Map.fetch!(struct, name)
      end
    )
  end

  defp storage do
    Application.get_env(:coxir, :storage, Coxir.Storage.Default)
  end
end
