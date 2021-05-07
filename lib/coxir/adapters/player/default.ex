defmodule Coxir.Player.Default do
  @moduledoc """
  Work in progress.
  """
  use GenServer

  def ready(_player, _audio) do
    :ok
  end

  def invalidate(_player) do
    :ok
  end

  def play(_player, _playable) do
    :noop
  end

  def pause(_player) do
    :noop
  end

  def resume(_player) do
    :noop
  end

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  def init(state) do
    {:ok, state}
  end
end
