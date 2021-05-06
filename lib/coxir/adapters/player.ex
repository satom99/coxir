defmodule Coxir.Player do
  @moduledoc """
  Work in progress.
  """
  defstruct [
    :udp_socket,
    :remote_ip,
    :remote_port
  ]

  @type t :: %__MODULE__{}

  @type player :: pid | GenServer.name()

  @type playable :: term

  @callback child_spec(term) :: GenServer.child_spec()

  @callback update(player, t) :: :ok

  @callback play(player, playable) :: :ok

  @callback pause(player) :: :ok

  @callback resume(player) :: :ok
end
