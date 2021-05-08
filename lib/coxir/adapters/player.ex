defmodule Coxir.Player do
  @moduledoc """
  Work in progress.
  """
  alias Coxir.Voice.Audio

  @type player :: GenServer.server()

  @type playable :: term

  @type start :: {playable, keyword}

  @callback child_spec(start) :: Supervisor.child_spec()

  @callback ready(player, Audio.t()) :: :ok

  @callback invalidate(player) :: :ok

  @callback pause(player) :: :ok

  @callback resume(player) :: :ok

  @callback playing?(player) :: boolean
end
