defmodule Coxir.Limiter do
  @moduledoc """
  Work in progress.
  """
  @type bucket :: String.t()

  @type limit :: integer

  @type reset :: integer

  @callback put(bucket, limit, reset) :: :ok

  @callback hit(bucket) :: :ok | {:error, timeout}

  @callback child_spec(term) :: Supervisor.child_spec()

  defmacro __using__(_options) do
    quote location: :keep do
      @behaviour Coxir.Limiter

      import Coxir.Limiter
    end
  end

  def put(bucket, limit, reset) do
    limiter().put(bucket, limit, reset)
  end

  def hit(bucket) do
    limiter().hit(bucket)
  end

  def child_spec(term) do
    limiter().child_spec(term)
  end

  def time_now do
    DateTime.to_unix(DateTime.utc_now(), :millisecond)
  end

  defp limiter do
    Application.get_env(:coxir, :limiter, Coxir.Limiter.Default)
  end
end
