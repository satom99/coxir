defmodule Coxir.Gateway.Consumer do
  @moduledoc """
  Work in progress.
  """
  use ConsumerSupervisor

  alias __MODULE__

  defstruct [
    :dispatcher,
    :module
  ]

  def start_link(state) do
    ConsumerSupervisor.start_link(__MODULE__, state)
  end

  def init(%Consumer{dispatcher: dispatcher, module: module}) do
    children = [
      get_handler_spec(module)
    ]

    options = [
      strategy: :one_for_one,
      subscribe_to: [dispatcher]
    ]

    ConsumerSupervisor.init(children, options)
  end

  def start_handler(module, event) do
    Task.start_link(fn ->
      module.handle_event(event)
    end)
  end

  defp get_handler_spec(module) do
    %{
      id: Consumer,
      start: {Consumer, :start_handler, [module]},
      restart: :temporary
    }
  end
end
