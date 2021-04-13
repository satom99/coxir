defmodule Coxir.Limiter do
  @moduledoc """
  Work in progress.
  """
  @type bucket :: String.t()

  @callback put(bucket, integer) :: :ok

  @callback hit(bucket) :: :ok | {:error, integer}

  @callback child_spec(term) :: Supervisor.child_spec()

  @optional_callbacks [child_spec: 0]
end
