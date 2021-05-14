defmodule Coxir.Voice do
  @moduledoc """
  Allows for interaction with Discord voice channels.
  """
  use Supervisor

  alias Coxir.Gateway
  alias Coxir.Gateway.Session
  alias Coxir.Gateway.Payload.UpdateVoiceState
  alias Coxir.{Guild, Channel, VoiceState}
  alias Coxir.Voice.Instance
  alias Coxir.Player
  alias __MODULE__

  @typedoc """
  The options that must be passed to `join/2`.
  """
  @type join_options :: [
          as: Gateway.gateway(),
          self_deaf: boolean | false,
          self_mute: boolean | false
        ]

  @typedoc """
  The options that can be passed to `play/3`.
  """
  @type play_options :: [player: Player.t() | Player.Default] | Player.options()

  @typedoc """
  The options that must be passed to `leave/2`.
  """
  @type leave_options :: [as: Gateway.gateway()]

  @doc """
  Joins a given voice channel.

  If the user is already in the channel, the function acts as a no-op.

  If the user is in a different channel of the same guild, it will stop playing and then switch.
  """
  @spec join(Channel.t(), join_options) :: Instance.instance()
  def join(%Channel{id: channel_id, guild_id: guild_id}, options) do
    gateway = Keyword.fetch!(options, :as)
    user_id = Gateway.get_user_id(gateway)

    instance = ensure_instance(gateway, user_id, guild_id)
    has_endpoint? = Instance.has_endpoint?(instance)
    same_channel? = Instance.get_channel_id(instance) == channel_id

    if not has_endpoint? or not same_channel? do
      update_voice_state(gateway, guild_id, channel_id, options)
    end

    if not same_channel? do
      stop_playing(instance)
    end

    instance
  end

  @doc """
  Begins playing audio on a given instance.

  Refer to the documentation of the player in use for more information on the arguments.

  If no custom player is provided, the default `Coxir.Player.Default` will be used.
  """
  @spec play(Instance.instance(), Player.playable(), play_options) :: :ok | {:error, term}
  def play(instance, playable, options \\ []) do
    player_module = Keyword.get(options, :player, Player.Default)
    Instance.play(instance, player_module, playable, options)
  end

  @doc """
  Pauses audio playback on a given instance.
  """
  @spec pause(Instance.instance()) :: :ok | {:error, :no_player}
  def pause(instance) do
    Instance.pause(instance)
  end

  @doc """
  Resumes audio playback on a given instance.
  """
  @spec resume(Instance.instance()) :: :ok | {:error, :no_player}
  def resume(instance) do
    Instance.resume(instance)
  end

  @doc """
  Returns whether audio is currently playing on a given instance.
  """
  @spec playing?(Instance.instance()) :: boolean
  def playing?(instance) do
    Instance.playing?(instance)
  end

  @doc """
  Stops playing audio on a given instance.
  """
  @spec stop_playing(Instance.instance()) :: :ok
  def stop_playing(instance) do
    Instance.stop_playing(instance)
  end

  @doc """
  Leaves from a given voice channel, or the active voice channel for a guild.
  """
  @spec leave(Guild.t() | Channel.t(), leave_options) :: :ok
  def leave(%Guild{id: guild_id}, options) do
    channel = %Channel{guild_id: guild_id}
    leave(channel, options)
  end

  def leave(%Channel{guild_id: guild_id}, as: gateway) do
    user_id = Gateway.get_user_id(gateway)

    terminate_instance(user_id, guild_id)

    update_voice_state(gateway, guild_id, nil)
  end

  @doc false
  def update_voice_state(gateway, guild_id, channel_id, options \\ []) do
    channel = %Channel{id: channel_id, guild_id: guild_id}
    session = Gateway.get_shard(gateway, channel)

    params =
      options
      |> Map.new()
      |> Map.put(:guild_id, guild_id)
      |> Map.put(:channel_id, channel_id)

    update_voice_state = UpdateVoiceState.cast(params)

    Session.update_voice_state(session, update_voice_state)
  end

  @doc false
  def update(user_id, guild_id, %VoiceState{channel_id: nil}) do
    terminate_instance(user_id, guild_id)
  end

  def update(user_id, guild_id, struct) do
    if instance = get_instance(user_id, guild_id) do
      Instance.update(instance, struct)
    end
  end

  @doc false
  def child_spec(term) do
    super(term)
  end

  @doc false
  def start_link(state) do
    Supervisor.start_link(__MODULE__, state, name: Voice)
  end

  @doc false
  def init(_state) do
    Supervisor.init([], strategy: :one_for_one)
  end

  defp get_instance(user_id, guild_id) do
    children = Supervisor.which_children(Voice)

    Enum.find_value(
      children,
      fn {id, pid, _type, _modules} ->
        if id == {user_id, guild_id}, do: pid
      end
    )
  end

  defp ensure_instance(gateway, user_id, guild_id) do
    instance_spec = generate_instance_spec(gateway, user_id, guild_id)

    case Supervisor.start_child(Voice, instance_spec) do
      {:ok, instance} ->
        instance

      {:error, {:already_started, instance}} ->
        instance

      {:error, :already_present} ->
        terminate_instance(user_id, guild_id)
        ensure_instance(gateway, user_id, guild_id)
    end
  end

  defp terminate_instance(user_id, guild_id) do
    Supervisor.terminate_child(Voice, {user_id, guild_id})
    Supervisor.delete_child(Voice, {user_id, guild_id})
  end

  defp generate_instance_spec(gateway, user_id, guild_id) do
    state = %Instance{gateway: gateway, user_id: user_id, guild_id: guild_id}
    spec = Instance.child_spec(state)
    %{spec | id: {user_id, guild_id}}
  end
end
