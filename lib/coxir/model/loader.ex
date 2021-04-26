defmodule Coxir.Model.Loader do
  @moduledoc """
  Work in progress.
  """
  import Ecto
  import Ecto.Changeset
  import Coxir.Model.Helper

  alias Ecto.Association.{NotLoaded, BelongsTo, Has}
  alias Coxir.{Model, Storage}

  @default_options %{
    force: false,
    storage: true,
    fetch: true
  }

  @type preloads :: atom | list(atom) | [{atom, preloads}]

  @type options :: keyword

  @spec load(Model.model(), list(map)) :: list(Model.instance())
  @spec load(Model.model(), map) :: Model.instance()
  def load(model, objects) when is_list(objects) do
    Enum.map(objects, &load(model, &1))
  end

  def load(model, object) do
    model
    |> struct()
    |> loader(object)
  end

  @spec get(Model.model(), Model.key(), options) :: Model.instance() | nil
  def get(model, key, options) do
    options = Enum.into(options, @default_options)
    getter(model, key, options)
  end

  @spec preload(list(Model.instance()), preloads, options) :: list(Model.instance())
  @spec preload(Model.instance(), preloads, options) :: Model.instance()
  def preload(structs, preloads, options) when is_list(structs) do
    Enum.map(
      structs,
      fn %model{} = struct ->
        model.preload(struct, preloads, options)
      end
    )
  end

  def preload(%model{} = struct, associations, options) when is_list(associations) do
    Enum.reduce(
      associations,
      struct,
      fn association, struct ->
        model.preload(struct, association, options)
      end
    )
  end

  def preload(%model{} = struct, {association, nested}, options) do
    struct = model.preload(struct, association, options)

    Map.update!(
      struct,
      association,
      fn %model{} = struct ->
        model.preload(struct, nested, options)
      end
    )
  end

  def preload(%model{} = struct, association, options) do
    reflection = get_association(model, association)
    options = Enum.into(options, @default_options)
    preloader(reflection, struct, options)
  end

  @spec update(Model.instance(), Enum.t(), options) :: Model.instance()
  def update(%model{} = struct, params, options) do
    struct
    |> get_key()
    |> model.patch(params, options)
    |> Storage.put()
  end

  @spec delete(Model.instance(), options) :: Model.instance()
  def delete(%model{} = struct, options) do
    key = get_key(struct)
    struct = model.drop(key, options)
    Storage.delete(model, key)
    struct
  end

  defp loader(%model{} = struct, object) do
    fields = get_fields(model)
    associations = get_associations(model)

    casted =
      struct
      |> cast(object, fields)
      |> apply_changes()

    casted
    |> cast(object, [])
    |> associer(associations)
    |> apply_changes()
    |> Storage.put()
  end

  defp associer(%{data: struct, params: params} = changeset, [association | associations]) do
    param = to_string(association)

    changeset =
      if Map.has_key?(params, param) do
        struct = void_association(struct, association)
        assoc = build_assoc(struct, association)

        caster = fn _struct, object ->
          assoc
          |> loader(object)
          |> change()
        end

        changeset
        |> Map.put(:data, struct)
        |> cast_assoc(association, with: caster)
      else
        changeset
      end

    associer(changeset, associations)
  end

  defp associer(changeset, []) do
    changeset
  end

  defp void_association(%model{} = struct, name) do
    value =
      case get_association(model, name) do
        %{cardinality: :one} -> nil
        %{cardinality: :many} -> []
      end

    Map.put(struct, name, value)
  end

  defp getter(model, key, %{storage: true} = options) do
    with nil <- Storage.get(model, key) do
      options = %{options | storage: false}
      getter(model, key, options)
    end
  end

  defp getter(model, key, %{fetch: true} = options) do
    options = Keyword.new(options)
    model.fetch(key, options)
  end

  defp getter(_model, _key, _options) do
    nil
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
          :many -> model.fetch_many(owner_value, field, options)
        end
      end

    result = storage || fetch

    resolved =
      with nil when cardinality == :many <- result do
        []
      end

    Map.put(struct, field, resolved)
  end
end
