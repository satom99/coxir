defmodule Coxir.Voice do
  @moduledoc """
  Work in progress.
  """
  use DynamicSupervisor

  def start_link(state) do
    DynamicSupervisor.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(_state) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
