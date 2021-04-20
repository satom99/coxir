defmodule Coxir.Gateway.Dispatcher do
  @moduledoc """
  Work in progress.
  """
  use GenStage

  alias Coxir.Model.Loader
  alias Coxir.Message

  def start_link(producer) do
    GenStage.start_link(__MODULE__, producer)
  end

  def init(producer) do
    {:producer_consumer, nil, subscribe_to: [producer]}
  end

  def handle_events(events, _from, state) do
    events =
      Enum.map(
        events,
        fn {name, object} ->
          object = sanitize(object)
          handle_event(name, object)
        end
      )

    {:noreply, events, state}
  end

  defp handle_event(:MESSAGE_CREATE, object) do
    message = Loader.load(Message, object)
    {:MESSAGE_CREATE, message}
  end

  defp handle_event(name, object) do
    {name, object}
  end

  defp sanitize(object) when is_map(object) do
    Map.new(object, &sanitize/1)
  end

  defp sanitize({key, value}) do
    {to_string(key), sanitize(value)}
  end

  defp sanitize(term) do
    term
  end
end
