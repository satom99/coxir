defmodule Coxir.Storage.Helper do
  @moduledoc """
  Common helper functions for `Coxir.Storage` implementations.
  """
  import Ecto.Changeset

  alias Coxir.Model

  @spec merge(Model.object(), Model.object()) :: Model.object()
  def merge(%model{} = base, %model{} = overwrite) do
    fields = get_fields(model)
    params = Map.take(overwrite, fields)

    assocs = get_associations(model)
    assocs = Map.take(overwrite, assocs)

    base
    |> change(params)
    |> apply_changes
    |> Map.merge(assocs)
  end

  @spec get_key(Model.object()) :: term
  def get_key(%model{} = struct) do
    primary = model.__schema__(:primary_key)

    case take_fields(struct, primary) do
      [single] -> single
      multiple -> List.to_tuple(multiple)
    end
  end

  @spec get_fields(Model.name()) :: list(atom)
  def get_fields(model) do
    model.__schema__(:fields)
  end

  @spec get_values(Model.object()) :: list(term)
  def get_values(%model{} = struct) do
    fields = get_fields(model)
    take_fields(struct, fields)
  end

  defp get_associations(model) do
    model.__schema__(:associations)
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
