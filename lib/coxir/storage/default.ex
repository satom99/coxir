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
    :ets.new(@table, [{:read_concurrency, true}, :named_table, :public])
    {:ok, state}
  end

  def handle_call({:create_table, model}, _from, state) do
    table = :ets.new(model, [:public])
    :ets.insert(@table, {model, table})
    {:reply, table, state}
  end

  def put(%model{id: primary} = struct) do
    table = get_table(model)

    struct =
      case :ets.lookup(table, primary) do
        [stored] ->
          stored = from_record(model, stored)
          merge(stored, struct)

        _none ->
          struct
      end

    record = to_record(struct)
    :ets.insert(table, record)

    struct
  end

  def all(model) do
    model
    |> get_table
    |> :ets.tab2list()
    |> Enum.map(&from_record(model, &1))
  end

  def get(model, primary) do
    record =
      model
      |> get_table
      |> :ets.lookup(primary)
      |> List.first()

    if record do
      from_record(model, record)
    end
  end

  def delete(%model{id: primary} = struct) do
    table = get_table(model)
    :ets.delete(table, primary)
    struct
  end

  defp get_table(model) do
    case :ets.lookup(@table, model) do
      [{^model, table}] ->
        table

      _none ->
        GenServer.call(__MODULE__, {:create_table, model})
    end
  end

  defp to_record(%model{} = struct) do
    fields = get_fields(model)

    values =
      Enum.map(
        fields,
        fn name ->
          Map.fetch!(struct, name)
        end
      )

    List.to_tuple(values)
  end

  defp from_record(model, record) do
    fields = get_fields(model)
    values = Tuple.to_list(record)
    params = Enum.zip(fields, values)
    struct(model, params)
  end
end
