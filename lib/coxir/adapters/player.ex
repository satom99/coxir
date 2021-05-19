defmodule Coxir.Player do
  @moduledoc """
  Handles the audio sent through voice.
  """
  alias Coxir.Voice.Audio

  @typedoc """
  A module that implements the behaviour.
  """
  @type t :: module

  @typedoc """
  A player process.
  """
  @type player :: pid

  @typedoc """
  Specifies what can be played with the `t:t/0` in use.
  """
  @type playable :: term

  @typedoc """
  Specifies the options that can be passed to the `t:t/0` in use.
  """
  @type options :: keyword

  @typedoc """
  The argument that is passed to `c:child_spec/1`.
  """
  @type init_argument :: {playable, options}

  @doc """
  Must return a child specification from a `t:init_argument/0`.
  """
  @callback child_spec(init_argument) :: Supervisor.child_spec()

  @doc """
  Called when the connection to the Discord voice channel is ready.

  The received `t:Coxir.Voice.Audio.t/0` struct can be used to send audio.
  """
  @callback ready(player, Audio.t()) :: :ok

  @doc """
  Called when the connection to the Discord voice channel is lost.

  This invalidates the previously received `t:Coxir.Voice.Audio.t/0` struct.

  Thus the player should stop sending audio until `c:ready/2` is called again.
  """
  @callback invalidate(player) :: :ok

  @doc """
  Called to pause audio playback.
  """
  @callback pause(player) :: :ok

  @doc """
  Called to resume audio playback.
  """
  @callback resume(player) :: :ok

  @doc """
  Called to check whether audio playback is paused.
  """
  @callback playing?(player) :: boolean
end
