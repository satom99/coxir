defmodule Coxir.Model.Loader do
  @moduledoc """
  Work in progress.
  """
  import Ecto.Changeset
  import Coxir.Model.Helper

  alias Ecto.Association.{NotLoaded, BelongsTo, Has}
  alias Coxir.{Model, Storage}

  @spec load(Model.model(), map | list(map)) :: Model.object()
  def load(model, objects) when is_list(objects) do
    Enum.map(objects, &load(model, &1))
  end

  def load(model, object) do
    model
    |> struct()
    |> loader(object)
  end

  @spec preload(Model.instance(), atom, keyword) :: Model.instance()
  def preload(%model{} = struct, association, options) do
    reflection = get_association(model, association)
    options = default_options(options)
    preloader(reflection, struct, options)
  end

  defp loader(%model{} = struct, object) do
    fields = get_fields(model)
    associations = get_associations(model)

    struct
    |> cast(object, fields)
    |> associer(associations)
    |> apply_changes()
    |> Storage.put()
  end

  defp associer(%{data: struct, params: params} = changeset, [association | associations]) do
    param = to_string(association)

    struct =
      if Map.has_key?(params, param) do
        void_association(struct, association)
      else
        struct
      end

    changeset
    |> Map.put(:data, struct)
    |> cast_assoc(association, with: &associer/2)
    |> associer(associations)
  end

  defp associer(changeset, []) do
    changeset
  end

  defp associer(%_model{} = struct, object) do
    struct
    |> loader(object)
    |> change()
  end

  defp void_association(%model{} = struct, name) do
    value =
      case get_association(model, name) do
        %{cardinality: :one} -> nil
        %{cardinality: :many} -> []
      end

    Map.put(struct, name, value)
  end

  defp preloader(%{field: field} = reflection, struct, %{force: false} = options) do
    case Map.fetch!(struct, field) do
      %NotLoaded{} ->
        options = %{options | force: true}
        preloader(reflection, struct, options)

      _other ->
        struct
    end
  end

  defp preloader(%type{} = reflection, %model{} = struct, options)
       when type in [Has, BelongsTo] do
    %{storage: storage?, fetch: fetch?} = options
    %{owner_key: owner_key, related_key: related_key} = reflection
    %{cardinality: cardinality, related: related} = reflection
    %{field: field} = reflection

    owner_value = Map.fetch!(struct, owner_key)

    clauses = [{related_key, owner_value}]

    storage =
      if storage? do
        case cardinality do
          :one -> Storage.get(related, owner_value)
          :many -> Storage.all_by(related, clauses)
        end
      end

    options = Keyword.new(options)

    fetch =
      if is_nil(storage) and fetch? do
        case cardinality do
          :one -> related.fetch(owner_value, options)
          :many -> model.fetch_association(struct, field, options)
        end
      end

    result = storage || fetch

    resolved =
      with nil when cardinality == :many <- result do
        []
      end

    Map.put(struct, field, resolved)
  end

  defp default_options(options) do
    options
    |> Map.new()
    |> Map.put_new(:force, false)
    |> Map.put_new(:storage, true)
    |> Map.put_new(:fetch, true)
  end
end
