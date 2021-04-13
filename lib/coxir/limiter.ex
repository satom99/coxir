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

  @optional_callbacks [child_spec: 1]

  defmacro __using__(_options) do
    quote location: :keep do
      @behaviour Coxir.Limiter

      import Coxir.Limiter
    end
  end

  def time_now do
    DateTime.to_unix(DateTime.utc_now(), :millisecond)
  end
end
