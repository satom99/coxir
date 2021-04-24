defmodule Coxir.Model.Helper do
  @moduledoc """
  Work in progress.
  """
  import Ecto.Changeset

  alias Coxir.Model

  @spec merge(Model.instance(), Model.instance()) :: Model.instance()
  def merge(%model{} = base, %model{} = overwrite) do
    fields = get_fields(model)
    params = Map.take(overwrite, fields)

    assocs = get_associations(model)
    assocs = Map.take(overwrite, assocs)

    base
    |> cast(params, fields)
    |> apply_changes()
    |> Map.merge(assocs)
  end

  @spec get_key(Model.instance()) :: Model.key()
  def get_key(%model{} = struct) do
    primary = get_primary(model)

    case take_fields(struct, primary) do
      [single] -> single
      multiple -> List.to_tuple(multiple)
    end
  end

  @spec get_primary(Model.model()) :: list(atom)
  def get_primary(model) do
    model.__schema__(:primary_key)
  end

  @spec get_fields(Model.model()) :: list(atom)
  def get_fields(model) do
    model.__schema__(:fields) -- model.__schema__(:embeds)
  end

  @spec get_associations(Model.model()) :: list(atom)
  def get_associations(model) do
    model.__schema__(:associations)
  end

  @spec get_association(Model.model(), atom) :: struct
  def get_association(model, name) do
    model.__schema__(:association, name)
  end

  @spec get_values(Model.instance()) :: list
  def get_values(%model{} = struct) do
    fields = get_fields(model)
    take_fields(struct, fields)
  end

  defp take_fields(struct, fields) do
    Enum.map(
      fields,
      fn name ->
        Map.fetch!(struct, name)
      end
    )
  end
end
