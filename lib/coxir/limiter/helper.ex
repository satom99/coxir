defmodule Coxir.Limiter.Helper do
  @moduledoc """
  Common helper functions for `Coxir.Limiter` implementations.
  """
  alias Coxir.Limiter

  def time_now do
    DateTime.to_unix(DateTime.utc_now(), :millisecond)
  end

  def offset_now(offset) do
    time_now() + offset
  end

  def wait_hit(bucket) do
    with {:error, timeout} <- Limiter.hit(bucket) do
      Process.sleep(timeout)
      wait_hit(bucket)
    end
  end
end
