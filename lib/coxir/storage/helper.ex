defmodule Coxir.Storage.Helper do
  @moduledoc """
  Common helper functions for `Coxir.Storage` implementations.
  """
  import Ecto.Changeset

  def merge(%module{} = base, %module{} = overwrite) do
    fields = get_fields(module)
    params = Map.take(overwrite, fields)

    base
    |> change(params)
    |> apply_changes
  end

  def get_fields(module) do
    fields = module.__schema__(:fields)
    primary = module.__schema__(:primary_key)
    primary ++ (fields -- primary)
  end

  def get_values(%module{} = struct) do
    Enum.map(
      get_fields(module),
      fn name ->
        Map.fetch!(struct, name)
      end
    )
  end
end
