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

    children = [module]
  def init(%Consumer{dispatcher: dispatcher, module: module}) do

    options = [
      strategy: :one_for_one,
      subscribe_to: [dispatcher]
    ]

    ConsumerSupervisor.init(children, options)
  end
end
