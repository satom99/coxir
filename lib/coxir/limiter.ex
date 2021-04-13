defmodule Coxir.Limiter do
  @moduledoc """
  Work in progress.
  """
  @type bucket :: String.t()

  @callback put(bucket, integer) :: :ok

  @callback hit(bucket) :: :ok | {:error, integer}

  @callback start_link() :: GenServer.on_start()

  @optional_callbacks [start_link: 0]
end
