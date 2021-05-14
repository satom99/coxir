defmodule Coxir.Gateway.Producer do
  @moduledoc """
  Work in progress.
  """
  use GenStage

  alias GenStage.BroadcastDispatcher

  @type producer :: pid

  def start_link(state) do
    GenStage.start_link(__MODULE__, state)
  end

  def init(_state) do
    state = {:queue.new(), 0}
    {:producer, state, dispatcher: BroadcastDispatcher}
  end

  def handle_demand(requested, {queue, demand}) do
    dispatch(queue, demand + requested)
  end

  def handle_cast({:notify, event}, {queue, demand}) do
    queue = :queue.in(event, queue)
    dispatch(queue, demand)
  end

  def notify(producer, event) do
    GenStage.cast(producer, {:notify, event})
  end

  defp dispatch(demand, queue, events \\ [])

  defp dispatch(queue, 0, events) do
    events = Enum.reverse(events)
    {:noreply, events, {queue, 0}}
  end

  defp dispatch(queue, demand, events) do
    case :queue.out(queue) do
      {{:value, event}, queue} ->
        events = [event | events]
        dispatch(queue, demand - 1, events)

      _other ->
        events = Enum.reverse(events)
        {:noreply, events, {queue, demand}}
    end
  end
end
