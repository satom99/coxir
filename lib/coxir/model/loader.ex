defmodule Coxir.Model.Loader do
  @moduledoc """
  Work in progress.
  """
  import Ecto
  import Ecto.Changeset
  import Coxir.Model.Helper

  alias Ecto.Association.{NotLoaded, BelongsTo, Has}
  alias Coxir.{Model, Storage, API}
  alias Coxir.API.Error

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

  @spec unload(Model.instance()) :: :ok
  def unload(%model{} = struct) do
    key = get_key(struct)

    if storable?(model) do
      Storage.delete(model, key)
    else
      :ok
    end
  end

  @spec get(Model.model(), Model.key(), options) :: Model.instance() | Error.t()
  def get(model, key, options) do
    options = Enum.into(options, @default_options)
    getter(model, key, options)
  end

  @spec get!(Model.model(), Model.key(), options) :: Model.instance()
  def get!(model, key, options) do
    with %Error{} = error <- get(model, key, options) do
      raise(error)
    end
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
    updater = fn value ->
      with %model{} = struct <- value do
        model.preload(struct, nested, options)
      end
    end

    struct
    |> model.preload(association, options)
    |> Map.update!(association, updater)
  end

  def preload(%model{} = struct, association, options) when is_atom(association) do
    reflection = get_association(model, association)
    options = Enum.into(options, @default_options)
    preloader(reflection, struct, options)
  end

  @spec preload!(list(Model.instance()), preloads, options) :: list(Model.instance())
  @spec preload!(Model.instance(), preloads, options) :: Model.instance()
  def preload!(structs, preloads, options) when is_list(structs) do
    Enum.map(
      structs,
      fn struct ->
        preload!(struct, preloads, options)
      end
    )
  end

  def preload!(%_model{} = struct, associations, options) when is_list(associations) do
    Enum.reduce(
      associations,
      struct,
      fn association, struct ->
        preload!(struct, association, options)
      end
    )
  end

  def preload!(%_model{} = struct, {association, nested}, options) do
    updater = fn value ->
      with %_model{} = struct <- value do
        preload!(struct, nested, options)
      end
    end

    struct
    |> preload!(association, options)
    |> Map.update!(association, updater)
  end

  def preload!(%model{} = struct, association, options) do
    with %{^association => %Error{} = error} <- model.preload(struct, association, options) do
      raise(error)
    end
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
    params = Map.new(params)

    case model.patch(key, params, options) do
      :ok ->
        struct = loader(struct, params)
        {:ok, struct}

      {:ok, object} ->
        struct = load(model, object)
        {:ok, struct}

      other ->
        other
    end
  end

  @spec delete(Model.instance(), options) :: result
  def delete(%model{} = struct, options) do
    key = get_key(struct)

    result =
      case model.drop(key, options) do
        :ok ->
          {:ok, struct}

        {:ok, object} ->
          struct = load(model, object)
          {:ok, struct}

        other ->
          other
      end

    with {:ok, struct} <- result do
      unload(struct)
      {:ok, struct}
    end
  end

  defp loader(%model{} = struct, object) do
    fields = get_fields(model)
    embeds = get_embeds(model)
    associations = get_associations(model)

    casted =
      struct
      |> cast(object, fields -- embeds)
      |> apply_changes()

    loaded =
      casted
      |> cast(object, [])
      |> embedder(embeds)
      |> associator(associations)
      |> apply_changes()

    if storable?(model) do
      Storage.put(loaded)
    else
      loaded
    end
  end

  defp embedder(%{params: params} = changeset, [embed | embeds]) do
    param = to_string(embed)

    changeset =
      if Map.has_key?(params, param) do
        caster = fn struct, object ->
          struct
          |> loader(object)
          |> change()
        end

        cast_embed(changeset, embed, with: caster)
      else
        changeset
      end

    embedder(changeset, embeds)
  end

  defp embedder(changeset, []) do
    changeset
  end

  defp associator(%{data: struct, params: params} = changeset, [association | associations]) do
    param = to_string(association)

    changeset =
      if Map.has_key?(params, param) do
        struct = void_association(struct, association)
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

    associator(changeset, associations)
  end

  defp associator(changeset, []) do
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
    storage =
      if storable?(model) do
        Storage.get(model, key)
      end

    with nil <- storage do
      options = %{options | storage: false}
      getter(model, key, options)
    end
  end

  defp getter(model, key, %{fetch: true} = options) do
    if function_exported?(model, :fetch, 2) do
      case model.fetch(key, options) do
        {:ok, object} ->
          load(model, object)

        {:error, error} ->
          error
      end
    end
  end

  defp getter(_model, _key, _options) do
    nil
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

    resolved =
      if not is_nil(owner_value) do
        get(related, owner_value, options)
      end

    %{struct | field => resolved}
  end

  defp preloader(%{cardinality: :many} = reflection, %model{} = struct, options) do
    %{owner_key: owner_key, related_key: related_key, related: related, field: field} = reflection
    %{storage: storage?, fetch: fetch?} = options

    owner_value = Map.fetch!(struct, owner_key)

    storage =
      if storage? and storable?(related) do
        clauses = [{related_key, owner_value}]
        Storage.all_by(related, clauses)
      end

    fetch =
      if is_nil(storage) and fetch? do
        case model.fetch_many(owner_value, field, options) do
          {:ok, objects} ->
            load(related, objects)

          {:error, error} ->
            error
        end
      end

    resolved = storage || fetch || []

    %{struct | field => resolved}
  end
end
