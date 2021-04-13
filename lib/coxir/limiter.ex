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
end
