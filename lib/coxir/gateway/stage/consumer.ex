defmodule Coxir.Gateway.Consumer do
  @moduledoc """
  Work in progress.
  """
  use ConsumerSupervisor

  defstruct [
    :dispatchers,
    :module
  ]

  alias __MODULE__

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
