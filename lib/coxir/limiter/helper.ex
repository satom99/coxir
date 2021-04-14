defmodule Coxir.Limiter.Helper do
  @moduledoc """
  Common helper functions for `Coxir.Limiter` implementations.
  """
  def time_now do
    DateTime.to_unix(DateTime.utc_now(), :millisecond)
  end

  def offset_now(offset) do
    time_now() + offset
  end
end
