defmodule Coxir.Gateway.Dispatcher do
  @moduledoc """
  Work in progress.
  """
  use GenStage

  def start_link(producer) do
    GenStage.start_link(__MODULE__, producer)
  end

  def init(producer) do
    {:producer_consumer, nil, subscribe_to: [producer]}
  end

  def handle_events(events, _from, state) do
    {:noreply, events, state}
  end
end
