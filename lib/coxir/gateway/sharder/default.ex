defmodule Coxir.Gateway.Sharder.Default do
  @moduledoc """
  Work in progress.
  """
  use Supervisor

  def start_link(options) do
    Supervisor.start_link(__MODULE__, options)
  end

  def init(_options) do
    children = []

    options = [
      strategy: :one_for_one
    ]

    Supervisor.init(children, options)
  end
end
