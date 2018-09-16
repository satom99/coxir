defmodule Coxir.Cache.TTL do
  @behaviour Coxir.Cache.Cache

  def insert(cache, data) do
    "#{cache}s"
    |> String.to_atom()
    |> SimpleTTL.put(data)
  end

  def get(cache, data) do
    "#{cache}s"
    |> String.to_atom()
    |> SimpleTTL.get(data)
  end

  def delete(cache, data) do
    "#{cache}s"
    |> String.to_atom()
    |> SimpleTTL.delete(data)
  end
end
