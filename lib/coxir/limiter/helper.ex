defmodule Coxir.Limiter.Helper do
  @moduledoc """
  Common helper functions for `Coxir.Limiter` implementations.
  """
  alias Coxir.Limiter

  @spec time_now() :: non_neg_integer
  def time_now do
    DateTime.to_unix(DateTime.utc_now(), :millisecond)
  end

  @spec offset_now(non_neg_integer) :: non_neg_integer
  def offset_now(offset \\ 0) do
    time_now() + offset + offset_noise()
  end

  @spec wait_hit(Limiter.bucket()) :: :ok
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
