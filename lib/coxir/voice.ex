defmodule Coxir.Voice do
  @moduledoc """
  Work in progress.
  """
  use Supervisor

  alias Coxir.Gateway
  alias Coxir.Gateway.Session
  alias Coxir.Gateway.Payload.UpdateVoiceState
  alias Coxir.{Guild, Channel, VoiceState}
  alias Coxir.Voice.Instance
  alias Coxir.Player
  alias __MODULE__

  @spec join(Channel.t(), keyword) :: Instance.instance()
  def join(%Channel{id: channel_id, guild_id: guild_id}, options) do
    gateway = Keyword.fetch!(options, :as)
    user_id = Gateway.get_user_id(gateway)

    instance = ensure_instance(user_id, guild_id)
    has_endpoint? = Instance.has_endpoint?(instance)
    same_channel? = Instance.get_channel_id(instance) == channel_id

    if not has_endpoint? or not same_channel? do
      update_voice_state(gateway, guild_id, channel_id, options)
    end

    instance
  end

  @spec play(Instance.instance(), Player.playable(), keyword) :: :ok | {:error, term}
  def play(instance, playable, options \\ []) do
    player_module = Keyword.get(options, :player, Player.Default)
    Instance.play(instance, player_module, playable, options)
  end

  @spec pause(Instance.instance()) :: :ok | {:error, :already_paused} | {:error, :no_player}
  def pause(instance) do
    Instance.pause(instance)
  end

  @spec resume(Instance.instance()) :: :ok | {:error, :already_resumed} | {:error, :no_player}
  def resume(instance) do
    Instance.resume(instance)
  end

  @spec playing?(Instance.instance()) :: boolean
  def playing?(instance) do
    Instance.playing?(instance)
  end

  @spec stop_playing(Instance.instance()) :: :ok
  def stop_playing(instance) do
    Instance.stop_playing(instance)
  end

  @spec leave(Guild.t() | Channel.t(), keyword) :: :ok
  def leave(%Guild{id: guild_id}, options) do
    channel = %Channel{guild_id: guild_id}
    leave(channel, options)
  end

  def leave(%Channel{guild_id: guild_id}, as: gateway) do
    user_id = Gateway.get_user_id(gateway)

    terminate_instance(user_id, guild_id)

    update_voice_state(gateway, guild_id, nil)
  end

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

  def update(_gateway, user_id, guild_id, %VoiceState{channel_id: nil}) do
    terminate_instance(user_id, guild_id)
  end

  def update(gateway, user_id, guild_id, struct) do
    user_id
    |> ensure_instance(guild_id)
    |> Instance.update(gateway, struct)
  end

  def start_link(state) do
    Supervisor.start_link(__MODULE__, state, name: Voice)
  end

  def init(_state) do
    Supervisor.init([], strategy: :one_for_one)
  end

  defp ensure_instance(user_id, guild_id) do
    instance_spec = generate_instance_spec(user_id, guild_id)

    case Supervisor.start_child(Voice, instance_spec) do
      {:ok, instance} ->
        instance

      {:error, {:already_started, instance}} ->
        instance

      {:error, :already_present} ->
        terminate_instance(user_id, guild_id)
        ensure_instance(user_id, guild_id)
    end
  end

  defp terminate_instance(user_id, guild_id) do
    Supervisor.terminate_child(Voice, {user_id, guild_id})
    Supervisor.delete_child(Voice, {user_id, guild_id})
  end

  defp generate_instance_spec(user_id, guild_id) do
    state = %Instance{user_id: user_id, guild_id: guild_id}
    spec = Instance.child_spec(state)
    %{spec | id: {user_id, guild_id}}
  end
end
