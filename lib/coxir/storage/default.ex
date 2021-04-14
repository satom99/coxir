defmodule Coxir.Storage.Default do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Storage
  use GenServer

  @table __MODULE__

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    :ets.new(@table, [:named_table, :public, {:read_concurrency, true}])
    {:ok, state}
  end

  def handle_call({:create_table, module}, _from, state) do
    table =
      with nil <- lookup_table(module) do
        table = :ets.new(module, [:public])
        :ets.insert(@table, {module, table})
        table
      end

    {:reply, table, state}
  end

  def put(%module{id: primary} = struct) do
    table = get_table(module)

    struct =
      case :ets.lookup(table, primary) do
        [stored] ->
          stored = from_record(module, stored)
          merge(stored, struct)

        _none ->
          struct
      end

    record = to_record(struct)
    :ets.insert(table, record)

    struct
  end

  def all(module) do
    module
    |> get_table
    |> :ets.tab2list()
    |> Enum.map(&from_record(module, &1))
  end

  def get(module, primary) do
    record =
      module
      |> get_table
      |> :ets.lookup(primary)
      |> List.first()

    if record do
      from_record(module, record)
    end
  end

  def delete(%module{id: primary} = struct) do
    table = get_table(module)
    :ets.delete(table, primary)
    struct
  end

  defp get_table(module) do
    with nil <- lookup_table(module) do
      GenServer.call(__MODULE__, {:create_table, module})
    end
  end

  defp lookup_table(module) do
    case :ets.lookup(@table, module) do
      [{^module, table}] ->
        table

      _none ->
        nil
    end
  end

  defp to_record(struct) do
    struct
    |> get_values()
    |> List.to_tuple()
  end

  defp from_record(module, record) do
    fields = get_fields(module)
    values = Tuple.to_list(record)
    params = Enum.zip(fields, values)
    struct(module, params)
  end
end
