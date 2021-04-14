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

  def handle_call({:create_table, model}, _from, state) do
    table =
      with nil <- lookup_table(model) do
        table = :ets.new(model, [:public])
        :ets.insert(@table, {model, table})
        table
      end

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

  def get_by(model, clauses) do
    matcher = clauses_pattern(model, clauses)

    table = get_table(model)

    case :ets.match_object(table, matcher, 1) do
      {[record], _continuation} ->
        from_record(model, record)

      _other ->
        nil
    end
  end

  def select(model, clauses) do
    matcher = clauses_pattern(model, clauses)

    model
    |> get_table()
    |> :ets.match_object(matcher)
    |> Enum.map(&from_record(model, &1))
  end

  def delete(%model{id: primary} = struct) do
    table = get_table(model)
    :ets.delete(table, primary)
    struct
  end

  defp to_record(struct) do
    struct
    |> get_values()
    |> List.to_tuple()
  end

  defp from_record(model, record) do
    fields = get_fields(model)
    values = Tuple.to_list(record)
    params = Enum.zip(fields, values)
    struct(model, params)
  end

  defp clauses_pattern(model, clauses) do
    fields = get_fields(model)

    matcher =
      Enum.map(
        fields,
        fn name ->
          Keyword.get(clauses, name, :_)
        end
      )

    List.to_tuple(matcher)
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
