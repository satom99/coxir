defmodule Coxir.Model.Loader do
  @moduledoc """
  Work in progress.
  """
  import Ecto
  import Ecto.Changeset
  import Coxir.Model.Helper

  alias Ecto.Association.{NotLoaded, BelongsTo, Has}
  alias Coxir.{Model, Storage, API}

  @default_options %{
    force: false,
    storage: true,
    fetch: true
  }

  @type options :: Enum.t()

  @type preloads :: atom | list(atom) | [{atom, preloads}]

  @type result :: {:ok, Model.instance()} | API.result()

  @spec load(Model.model(), list(map)) :: list(Model.instance())
  @spec load(Model.model(), map) :: Model.instance()
  def load(model, objects) when is_list(objects) do
    Enum.map(objects, &load(model, &1))
  end

  def load(model, %model{} = struct) do
    struct
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
    updater = fn %model{} = struct ->
      model.preload(struct, nested, options)
    end

    struct
    |> model.preload(association, options)
    |> Map.update!(association, updater)
  end

  def preload(%model{} = struct, association, options) do
    reflection = get_association(model, association)
    options = Enum.into(options, @default_options)
    preloader(reflection, struct, options)
  end

  @spec create(Model.model(), Enum.t(), options) :: result
  def create(model, params, options) do
    params = Map.new(params)
    with {:ok, object} <- model.insert(params, options) do
      struct = load(model, object)
      {:ok, struct}
    end
  end

  @spec update(Model.instance(), Enum.t(), options) :: result
  def update(%model{} = struct, params, options) do
    key = get_key(struct)

    with {:ok, object} <- model.patch(key, params, options) do
      struct = load(model, object)
      {:ok, struct}
    end
  end

  @spec delete(Model.instance(), options) :: result
  def delete(%model{} = struct, options) do
    key = get_key(struct)

    with {:ok, object} <- model.drop(key, options) do
      struct = load(model, object)
      Storage.delete(model, key)
      {:ok, struct}
    end
  end

  defp loader(%model{} = struct, object) when is_map(object) do
    fields = get_fields(model)
    associations = get_associations(model)

    casted =
      struct
      |> cast(object, fields)
      |> apply_changes()

    casted
    |> cast(object, [])
    |> loader(associations)
    |> apply_changes()
    |> Storage.put()
  end

  defp loader(%{data: struct, params: params} = changeset, [association | associations]) do
    param = to_string(association)

    changeset =
      if Map.has_key?(params, param) do
        struct = %{struct | association => nil}
        changeset = %{changeset | data: struct}

        assoc = build_assoc(struct, association)

        caster = fn _struct, object ->
          assoc
          |> loader(object)
          |> change()
        end

        cast_assoc(changeset, association, with: caster)
      else
        changeset
      end

    loader(changeset, associations)
  end

  defp loader(changeset, []) do
    changeset
  end

  defp getter(model, key, %{storage: true} = options) do
    with nil <- Storage.get(model, key) do
      options = %{options | storage: false}
      getter(model, key, options)
    end
  end

  defp getter(model, key, %{fetch: true} = options) do
    case model.fetch(key, options) do
      {:ok, object} ->
        load(model, object)

      {:error, 404, _error} ->
        nil
    end
  end

  defp getter(_model, _key, _options) do
    nil
  end

  defp preloader(nil, _struct, _options) do
    raise "Cannot preload unknown association."
  end

  defp preloader(%type{}, _struct, _options) when type not in [Has, BelongsTo] do
    raise "#{type} associations cannot be preloaded."
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

  defp preloader(%{cardinality: :one} = reflection, struct, options) do
    %{owner_key: owner_key, related: related, field: field} = reflection
    owner_value = Map.fetch!(struct, owner_key)
    resolved = get(related, owner_value, options)
    %{struct | field => resolved}
  end

  defp preloader(%{cardinality: :many} = reflection, %model{} = struct, options) do
    %{owner_key: owner_key, related_key: related_key, related: related, field: field} = reflection
    %{storage: storage?, fetch: fetch?} = options

    owner_value = Map.fetch!(struct, owner_key)

    storage =
      if storage? do
        clauses = [{related_key, owner_value}]
        Storage.all_by(related, clauses)
      end

    fetch =
      if is_nil(storage) and fetch? do
        {:ok, objects} = model.fetch_many(owner_value, field, options)
        load(related, objects)
      end

    resolved = storage || fetch || []

    %{struct | field => resolved}
  end
end
