defmodule Coxir.Struct do
  @moduledoc false

  defmacro __using__(_opts) do
    quote location: :keep do
      alias Coxir.API

      @table __MODULE__
      |> Module.split
      |> List.last
      |> String.downcase
      |> String.to_atom

      defp put(map, key, value) do
        case map do
          %{error: _error} ->
            map
          _object ->
            Map.put(map, key, value)
        end
      end

      defp replace(map, key, function) do
        map
        |> Map.get(key)
        |> case do
          nil -> nil
          list when is_list(list) ->
            Enum.map(list, function)
          value ->
            function.(value)
        end
        |> case do
          nil ->
            map
          value ->
            new = key
            |> Atom.to_string
            |> String.replace_trailing("_id", "")
            |> String.to_atom

            Map.put(map, new, value)
        end
      end

      @doc """
      Fetches a cached #{@table} object.

      Returns an object if found
      and `nil` otherwise.
      """
      @spec get(String.t()) :: map | nil

      def get(%{id: id}), do: get(id)
      def get(id) do
        fetch(id)
        |> case do
          nil -> nil
          data -> pretty(data)
        end
      end

      @doc """
      Filters the cached #{@table} objects.

      Returns a list of matched objects.
      """
      @spec select(map) :: list

      def select(pattern \\ %{}) do
        :ets.tab2list(@table)
        |> Enum.map(&decode/1)
        |> Enum.filter(
          fn struct ->
            pattern
            |> Map.to_list
            |> Enum.filter(
              fn {key, value} ->
                struct
                |> Map.get(key)
                != value
              end
            )
            |> length
            == 0
          end
        )
      end

      @doc false
      def remove(%{id: id}), do: remove(id)
      def remove(id) do
        :ets.delete @table, {:id, id}
      end

      @doc false
      def pretty(struct), do: struct

      @doc false
      def update(data) do
        data = data
        |> fetch
        |> case do
          nil ->
            data
          struct ->
            Map.merge(struct, data)
        end

        :ets.insert @table, encode(data)
      end

      defp fetch(%{id: id}), do: fetch(id)
      defp fetch(id) do
        case :ets.lookup(@table, {:id, id}) do
          [entry] ->
            decode(entry)
          [] -> nil
        end
      end

      defp encode(data) do
        data
        |> Map.to_list
        |> List.insert_at(0, {:id, data.id})
        |> List.to_tuple
      end

      defp decode(data) do
        data
        |> Tuple.to_list
        |> Map.new
      end

      defoverridable [get: 1]
      defoverridable [pretty: 1]
    end
  end

  @tables [:user, :guild, :role, :member, :channel, :message]

  def create_tables do
    for table <- @tables do
      :ets.new table, [:set, :public, :named_table]
    end
  end
end
