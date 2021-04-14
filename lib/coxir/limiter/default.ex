defmodule Coxir.Limiter.Default do
  @moduledoc """
  Stores bucket information in ets.
  """
  use Coxir.Limiter
  use GenServer

  @table __MODULE__

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
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
            {:>, :"$2", 0}
          }
        ],
        [
          {
            {:"$1", {:-, :"$2", 1}, :"$3"}
          }
        ]
      },
      {
        {:"$1", :"$2", :"$3"},
        [
          {
            :andalso,
            {:==, :"$1", bucket},
            {:<, {:-, :"$3", time_now()}, 0}
          }
        ],
        [
          {
            {:"$1", :"$2", offset_now(5000)}
          }
        ]
      }
    ]

    if :ets.select_replace(@table, matcher) > 0 do
      :ok
    else
      case :ets.lookup(@table, bucket) do
        [{^bucket, _limit, reset}] ->
          timeout = reset - time_now()
          {:error, timeout}

        _none ->
          :ok
      end
    end
  end
end
