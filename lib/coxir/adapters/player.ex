defmodule Coxir.Player do
  @moduledoc """
  Handles the audio sent through voice.
  """
  alias Coxir.Voice.Audio

  @type player :: pid

  @type playable :: term

  @type options :: keyword

  @type start :: {playable, options}

  @callback child_spec(start) :: Supervisor.child_spec()

  @callback ready(player, Audio.t()) :: :ok

  @callback invalidate(player) :: :ok

  @callback pause(player) :: :ok

  @callback resume(player) :: :ok

  @callback playing?(player) :: boolean
end
