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

defmodule Coxir.Limiter.Default do
  @moduledoc """
  Work in progress.
  """
  use GenServer
  use Coxir.Limiter

  @table __MODULE__

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(state) do
    :ets.new(@table, [:named_table, :public])
    {:ok, state}
  end

  def put(bucket, limit, reset) do
    matcher = [
      {
        {:"$1", :"$2", :"$3"},
        [
          {
            :andalso,
            {:==, :"$1", bucket},
            {
              :orelse,
              {:>, :"$2", limit},
              {:<, :"$3", reset}
            }
          }
        ],
        [
          {
            {:"$1", limit, reset}
          }
        ]
      }
    ]

    if not :ets.insert_new(@table, [{bucket, limit, reset}]) do
      :ets.select_replace(@table, matcher)
    end

    :ok
  end

  def hit(bucket) do
    matcher = [
      {
        {:"$1", :"$2", :"$3"},
        [
          {
            :andalso,
            {:==, :"$1", bucket},
            {
              :orelse,
              {:>, :"$2", 0},
              {:<, {:-, :"$3", time_now()}, 0}
            }
          }
        ],
        [
          {
            {:"$1", {:-, :"$2", 1}, :"$3"}
          }
        ]
      }
    ]

    if :ets.select_replace(@table, matcher) > 0 do
      :ok
    else
      reset = :ets.lookup_element(@table, bucket, 3)
      timeout = reset - time_now()
      {:error, timeout}
    end
  rescue
    _error -> :ok
  end
end
