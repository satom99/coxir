defmodule Coxir.Voice.Instance do
  @moduledoc """
  Work in progress.
  """
  use GenServer, restart: :transient

  alias Coxir.VoiceState
  alias Coxir.Gateway.Payload.VoiceServerUpdate
  alias Coxir.Voice.{Session, Audio}
  alias Coxir.Voice
  alias __MODULE__

  @type instance :: pid

  defstruct [
    :player_module,
    :player,
    :gateway,
    :user_id,
    :guild_id,
    :channel_id,
    :session_id,
    :endpoint_host,
    :endpoint_port,
    :token,
    :session,
    :audio
  ]

  @update_session {:continue, :update_session}

  def has_endpoint?(instance) do
    GenServer.call(instance, :has_endpoint?)
  end

  def get_channel_id(instance) do
    GenServer.call(instance, :get_channel_id)
  end

  def play(instance, player_module, playable, options) do
    GenServer.call(instance, {:play, player_module, playable, options})
  end

  def pause(instance) do
    GenServer.call(instance, :pause)
  end

  def resume(instance) do
    GenServer.call(instance, :resume)
  end

  def stop_playing(instance) do
    GenServer.call(instance, :stop_playing)
  end

  def update(instance, struct) do
    GenServer.cast(instance, {:update, struct})
  end

  def update(instance, gateway, struct) do
    GenServer.cast(instance, {:update, gateway, struct})
  end

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  def init(state) do
    Process.flag(:trap_exit, true)
    {:ok, state}
  end

  def handle_continue(:update_session, %Instance{session_id: nil} = state) do
    {:noreply, state}
  end

  def handle_continue(:update_session, %Instance{endpoint_host: nil} = state) do
    {:noreply, state}
  end

  def handle_continue(:update_session, %Instance{session: nil} = state) do
    %Instance{
      user_id: user_id,
      guild_id: guild_id,
      session_id: session_id,
      endpoint_host: endpoint_host,
      endpoint_port: endpoint_port,
      token: token
    } = state

    session_state = %Session{
      instance: self(),
      user_id: user_id,
      guild_id: guild_id,
      session_id: session_id,
      endpoint_host: endpoint_host,
      endpoint_port: endpoint_port,
      token: token
    }

    {:ok, session} = Session.start_link(session_state)

    state = %{state | session: session}
    {:noreply, state}
  end

  def handle_continue(:update_session, %Instance{session: session} = state) do
    Process.exit(session, :restart)
    {:noreply, state}
  end

  def handle_call(:has_endpoint?, _from, %Instance{endpoint_host: endpoint_host} = state) do
    has_endpoint? = not is_nil(endpoint_host)
    {:reply, has_endpoint?, state}
  end

  def handle_call(:get_channel_id, _from, %Instance{channel_id: channel_id} = state) do
    {:reply, channel_id, state}
  end

  def handle_call(
        {:play, player_module, playable, options},
        _from,
        %Instance{player_module: player_module} = state
      ) do
    %{player: player} = state = update_player(state)

    result = player_module.play(player, playable, options)

    {:reply, result, state}
  end

  def handle_call(
        {:play, player_module, _playable, _options} = call,
        from,
        %Instance{player_module: nil} = state
      ) do
    state = %{state | player_module: player_module}
    handle_call(call, from, state)
  end

  def handle_call(
        {:play, _player_module, _playable, _options} = call,
        from,
        %Instance{player: player} = state
      ) do
    Process.exit(player, :kill)
    state = %{state | player_module: nil, player: nil}
    handle_call(call, from, state)
  end

  def handle_call(:pause, _from, %Instance{player: nil} = state) do
    {:reply, :no_player, state}
  end

  def handle_call(:pause, _from, %Instance{player_module: player_module, player: player} = state) do
    result = player_module.pause(player)
    {:reply, result, state}
  end

  def handle_call(:resume, _from, %Instance{player: nil} = state) do
    {:reply, :no_player, state}
  end

  def handle_call(:resume, _from, %Instance{player_module: player_module, player: player} = state) do
    result = player_module.resume(player)
    {:reply, result, state}
  end

  def handle_call(:stop_playing, _from, %Instance{player: nil} = state) do
    {:reply, :no_player, state}
  end

  def handle_call(
        :stop_playing,
        _from,
        %Instance{player_module: player_module, player: player} = state
      ) do
    result = player_module.stop_playing(player)
    {:reply, result, state}
  end

  def handle_cast({:update, struct}, state) do
    handle_update(struct, state)
  end

  def handle_cast({:update, gateway, struct}, state) do
    state = %{state | gateway: gateway}
    handle_update(struct, state)
  end

  def handle_info({:EXIT, session, :invalid}, %Instance{session: session} = state) do
    state = %{state | session_id: nil, endpoint_host: nil, session: nil, audio: nil}
    state = update_player(state)

    %Instance{gateway: gateway, guild_id: guild_id, channel_id: channel_id} = state
    Voice.update_voice_state(gateway, guild_id, channel_id)

    {:noreply, state}
  end

  def handle_info({:EXIT, session, :restart}, %Instance{session: session} = state) do
    state = %{state | session_id: nil, session: nil, audio: nil}
    state = update_player(state)
    {:noreply, state, @update_session}
  end

  def handle_info({:EXIT, session, :stop}, %Instance{session: session} = state) do
    {:stop, :normal, state}
  end

  def handle_info({:EXIT, player, :killed}, %Instance{player: player} = state) do
    state = %{state | player: nil}
    state = update_player(state)
    {:noreply, state}
  end

  def handle_info({:EXIT, _pid, _reason}, state) do
    {:noreply, state}
  end

  defp handle_update(%VoiceState{channel_id: channel_id, session_id: session_id}, state) do
    state = %{state | channel_id: channel_id, session_id: session_id}
    {:noreply, state, @update_session}
  end

  defp handle_update(%VoiceServerUpdate{endpoint: endpoint, token: token}, state) do
    [host, port] = String.split(endpoint, ":")
    endpoint_host = :binary.bin_to_list(host)
    endpoint_port = String.to_integer(port)

    state = %{state | endpoint_host: endpoint_host, endpoint_port: endpoint_port, token: token}
    {:noreply, state, @update_session}
  end

  defp handle_update(%Session{} = session_state, %Instance{session: session} = state) do
    %Session{
      udp_socket: udp_socket,
      audio_ip: audio_ip,
      audio_port: audio_port,
      ssrc: ssrc,
      secret_key: secret_key
    } = session_state

    audio = %Audio{
      session: session,
      udp_socket: udp_socket,
      ip: audio_ip,
      port: audio_port,
      ssrc: ssrc,
      secret_key: secret_key
    }

    state = %{state | audio: audio}
    state = update_player(state)
    {:noreply, state}
  end

  defp update_player(%Instance{player_module: nil} = state) do
    state
  end

  defp update_player(%Instance{player_module: player_module, audio: nil} = state) do
    %{player: player} = state = ensure_player(state)

    player_module.invalidate(player)

    state
  end

  defp update_player(%Instance{player_module: player_module, audio: audio} = state) do
    %{player: player} = state = ensure_player(state)

    player_module.ready(player, audio)

    state
  end

  defp ensure_player(%Instance{player_module: player_module, player: nil} = state) do
    %{start: start_mfa} = player_module.child_spec([])
    {module, function, arguments} = start_mfa

    {:ok, player} = apply(module, function, arguments)

    %{state | player: player}
  end

  defp ensure_player(state) do
    state
  end
end
