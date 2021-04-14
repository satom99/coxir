defmodule Coxir.Storage.Loader do
  @moduledoc """
  Work in progress.
  """
  alias Ecto.Association.{NotLoaded, BelongsTo, Has}
  alias Coxir.Storage

  def preload(%model{} = struct, association, options) do
    reflection = model.__schema__(:association, association)
    force = Keyword.get(options, :force, false)
    process(reflection, struct, force)
  end

  defp process(%{field: field} = reflection, struct, false) do
    case Map.fetch!(struct, field) do
      %NotLoaded{} ->
        process(reflection, struct, true)

      _other ->
        struct
    end
  end

  defp process(%type{} = reflection, struct, true) when type in [BelongsTo, Has] do
    %{owner_key: owner_key, related_key: related_key} = reflection
    %{cardinality: cardinality, related: related} = reflection
    %{field: field} = reflection

    owner_value = Map.fetch!(struct, owner_key)

    clauses = [{related_key, owner_value}]

    function =
      case cardinality do
        :one -> :get_by
        :many -> :select
      end

    resolved = apply(Storage, function, [related, clauses])

    Map.put(struct, field, resolved)
  end
end
