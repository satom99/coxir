defmodule Coxir.Stage.Producer do
  @moduledoc false

  use GenStage

  def start_link do
    GenStage.start_link __MODULE__, [], name: __MODULE__
  end

  def init(_state) do
    {:producer, {:queue.new(), 0}}
  end

  def notify(event) do
    __MODULE__
    |> GenStage.cast {:notify, event}
  end

  def handle_cast({:notify, event}, {queue, demand}) do
    :queue.in(event, queue)
    |> dispatch(demand, [])
  end

  def handle_demand(new, {queue, demand}) do
    queue
    |> dispatch(demand + new, [])
  end

  def dispatch(queue, 0, events) do
    {:noreply, Enum.reverse(events), {queue, 0}}
  end
  def dispatch(queue, demand, events) do
    case :queue.out(queue) do
      {{:value, event}, queue} ->
        dispatch(
          queue,
          demand - 1,
          [event | events]
        )
      _ ->
        {:noreply, Enum.reverse(events), {queue, demand}}
    end
  end
end
