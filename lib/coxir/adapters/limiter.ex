defmodule Coxir.Limiter do
  @moduledoc """
  Handles how rate limit buckets are stored.
  """
  @type bucket :: :global | String.t()

  @type limit :: non_neg_integer

  @type reset :: non_neg_integer

  @callback child_spec(term) :: Supervisor.child_spec()

  @callback put(bucket, limit, reset) :: :ok

  @callback hit(bucket) :: :ok | {:error, timeout}

  defmacro __using__(_options) do
    quote location: :keep do
      @behaviour Coxir.Limiter

      import Coxir.Limiter.Helper
    end
  end

  @doc false
  def child_spec(term) do
    limiter().child_spec(term)
  end

  @doc false
  def put(bucket, limit, reset) do
    limiter().put(bucket, limit, reset)
  end

  @doc false
  def hit(bucket) do
    limiter().hit(bucket)
  end

  defp limiter do
    Application.get_env(:coxir, :limiter, Coxir.Limiter.Default)
  end
end
