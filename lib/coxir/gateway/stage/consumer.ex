defmodule Coxir.Gateway.Consumer do
  @moduledoc """
  Work in progress.
  """
  use ConsumerSupervisor

  alias __MODULE__

  defstruct [
    :dispatcher,
    :handler
  ]

  def start_link(state) do
    ConsumerSupervisor.start_link(__MODULE__, state)
  end

  def init(%Consumer{dispatcher: dispatcher, handler: handler}) do
    children = [
      get_handler_spec(handler)
    ]

    options = [
      strategy: :one_for_one,
      subscribe_to: [dispatcher]
    ]

    ConsumerSupervisor.init(children, options)
  end

  def start_handler(handler, event) do
    Task.start_link(fn ->
      handler.handle_event(event)
    end)
  end

  defp get_handler_spec(handler) do
    %{
      id: Consumer,
      start: {Consumer, :start_handler, [handler]},
      restart: :temporary
    }
  end
end
