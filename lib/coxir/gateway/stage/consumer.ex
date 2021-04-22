defmodule Coxir.Gateway.Consumer do
  @moduledoc """
  Work in progress.
  """
  use ConsumerSupervisor

  alias Coxir.Gateway.Handler
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
      Handler.get_spec(handler)
    ]

    options = [
      strategy: :one_for_one,
      subscribe_to: [dispatcher]
    ]

    ConsumerSupervisor.init(children, options)
  end
end
