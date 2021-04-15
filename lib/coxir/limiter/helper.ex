defmodule Coxir.Limiter.Helper do
  @moduledoc """
  Common helper functions for `Coxir.Limiter` implementations.
  """
  alias Coxir.Limiter

  def time_now do
    DateTime.to_unix(DateTime.utc_now(), :millisecond)
  end

  def offset_now(offset \\ 0) do
    time_now() + offset + offset_noise()
  end

  def wait_hit(bucket) do
    with {:error, timeout} <- Limiter.hit(bucket) do
      Process.sleep(timeout + offset_noise())
      wait_hit(bucket)
    end
  end

  defp offset_noise do
    trunc(:rand.uniform() * 500)
  end
end
