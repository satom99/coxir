defmodule Coxir.Model.Loader do
  @moduledoc """
  Work in progress.
  """
  import Ecto.Changeset

  alias Ecto.Association.{NotLoaded, BelongsTo, Has}
  alias Coxir.Storage

  def load(model, params) do
    fields = model.__schema__(:fields)

    model
    |> struct()
    |> cast(params, fields)
    |> apply_changes()
    |> Storage.put()
  end

  def preload(%model{} = struct, association, options) do
    reflection = model.__schema__(:association, association)
    force = Keyword.get(options, :force, false)
    preloader(reflection, struct, force)
  end

  defp preloader(%{field: field} = reflection, struct, false) do
    case Map.fetch!(struct, field) do
      %NotLoaded{} ->
        preloader(reflection, struct, true)

      _other ->
        struct
    end
  end

  defp preloader(%type{} = reflection, struct, true) when type in [BelongsTo, Has] do
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
