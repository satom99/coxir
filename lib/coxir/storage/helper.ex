defmodule Coxir.Storage.Helper do
  @moduledoc """
  Common helper functions for `Coxir.Storage` implementations.
  """
  import Ecto.Changeset

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
end
