defmodule Coxir.Player do
  @moduledoc """
  Work in progress.
  """
  alias Coxir.Voice.Audio

  @type player :: GenServer.server()

  @type playable :: term

  @callback child_spec(term) :: Supervisor.child_spec()

  @callback ready(player, Audio.t()) :: :ok

  @callback invalidate(player) :: :ok

  @callback play(player, playable, keyword) :: :ok

  @callback pause(player) :: :ok

  @callback resume(player) :: :ok

  @callback stop_playing(player) :: :ok
end
