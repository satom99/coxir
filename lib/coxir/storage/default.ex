defmodule Coxir.Storage.Default do
  @moduledoc """
  Stores models in ets.
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
    table =
      with nil <- lookup_table(model) do
        table = :ets.new(model, [:public])
        :ets.insert(@table, {model, table})
        table
      end

    {:reply, table, state}
  end

  def put(%model{} = struct) do
    table = get_table(model)
    key = get_key(struct)

    struct =
      case :ets.lookup(table, key) do
        [record] ->
          stored = from_record(model, record)
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
    |> get_table()
    |> :ets.tab2list()
    |> Enum.map(&from_record(model, &1))
  end

  def select(model, clauses) do
    pattern = get_pattern(model, clauses)

    model
    |> get_table()
    |> :ets.match_object(pattern)
    |> Enum.map(&from_record(model, &1))
  end

  def get(model, key) do
    record =
      model
      |> get_table()
      |> :ets.lookup(key)
      |> List.first()

    if record do
      from_record(model, record)
    end
  end

  def get_by(model, clauses) do
    pattern = get_pattern(model, clauses)
    table = get_table(model)

    case :ets.match_object(table, pattern, 1) do
      {[record], _continuation} ->
        from_record(model, record)

      _other ->
        nil
    end
  end

  def delete(%model{} = struct) do
    key = get_key(struct)

    model
    |> get_table()
    |> :ets.delete(key)

    struct
  end

  def delete_by(model, clauses) do
    pattern = get_pattern(model, clauses)

    model
    |> get_table()
    |> :ets.match_delete(pattern)

    :ok
  end

  defp get_pattern(model, clauses) do
    fields = get_fields(model)

    pattern =
      Enum.map(
        fields,
        fn name ->
          Keyword.get(clauses, name, :_)
        end
      )

    List.to_tuple([:_ | pattern])
  end

  defp to_record(struct) do
    key = get_key(struct)
    values = get_values(struct)
    List.to_tuple([key | values])
  end

  defp from_record(model, record) do
    [_key | values] = Tuple.to_list(record)
    fields = get_fields(model)
    params = Enum.zip(fields, values)
    struct(model, params)
  end

  defp get_table(model) do
    with nil <- lookup_table(model) do
      GenServer.call(__MODULE__, {:create_table, model})
    end
  end

  defp lookup_table(model) do
    case :ets.lookup(@table, model) do
      [{^model, table}] ->
        table

      _none ->
        nil
    end
  end
end
