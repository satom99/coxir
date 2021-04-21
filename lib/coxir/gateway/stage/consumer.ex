defmodule Coxir.Gateway.Consumer do
  @moduledoc """
  Work in progress.
  """
  use ConsumerSupervisor

  alias __MODULE__

  defstruct [
    :dispatchers,
    :module
  ]

  def start_link(state) do
    ConsumerSupervisor.start_link(__MODULE__, state)
  end

  def init(%Consumer{dispatchers: dispatchers, module: module}) do
    children = [module]

    options = [
      strategy: :one_for_one,
      subscribe_to: dispatchers
    ]

    ConsumerSupervisor.init(children, options)
  end
end
