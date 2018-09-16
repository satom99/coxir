defmodule Coxir.Cache.ETS do
  @behaviour Coxir.Cache.Cache

  defdelegate insert(cache, data), to: :ets
  defdelegate get(cache, data), to: :ets, as: :lookup
  defdelegate delete(cache, data), to: :ets
end
