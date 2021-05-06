defmodule Coxir.Voice.Instance do
  @moduledoc """
  Work in progress.
  """
  use GenServer, restart: :transient

  alias Coxir.VoiceState
  alias Coxir.Gateway.Payload.VoiceServerUpdate
  alias Coxir.Voice.{Session, Audio}
  alias __MODULE__

  defstruct [
    {:player_module, Coxir.Player.Default},
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
    :audio_struct
  ]

  @start_player {:continue, :start_player}
  @start_session {:continue, :start_session}
  @ready_player {:continue, :ready_player}

  def get_player(instance) do
    GenServer.call(instance, :get_player)
  end

  def stop(instance) do
    GenServer.cast(instance, :stop)
  end

  def invalidate(instance) do
    GenServer.cast(instance, :invalidate)
  end

  def ready(instance, session_state) do
    GenServer.cast(instance, {:ready, session_state})
  end

  def update(instance, struct, gateway) do
    GenServer.cast(instance, {:update, struct, gateway})
  end

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  def init(state) do
    Process.flag(:trap_exit, true)
    {:ok, state, @start_player}
  end

  def handle_continue(:start_player, %Instance{player_module: player_module} = state) do
    %{start: {module, function, args}} = player_module.child_spec([])
    {:ok, player} = apply(module, function, args)

    state = %{state | player: player}
    {:noreply, state}
  end

  def handle_continue(:start_session, %Instance{session_id: nil} = state) do
    {:noreply, state}
  end

  def handle_continue(:start_session, %Instance{endpoint_host: nil} = state) do
    {:noreply, state}
  end

  def handle_continue(:start_session, %Instance{session: nil} = state) do
    values =
      state
      |> Map.from_struct()
      |> Keyword.new()
      |> Keyword.put(:instance, self())

    session_state = struct(Session, values)

    {:ok, session} = Session.start_link(session_state)

    state = %{state | session: session}
    {:noreply, state}
  end

  def handle_continue(:start_session, %Instance{session: session} = state) do
    Process.exit(session, :killed)
    handle_cast(:invalidate, state)

    state = %{state | session: nil}
    {:noreply, state, @start_session}
  end

  def handle_continue(
        :ready_player,
        %Instance{player_module: player_module, player: player, audio_struct: audio_struct} =
          state
      ) do
    player_module.ready(player, audio_struct)
    {:noreply, state}
  end

  def handle_call(:get_player, _from, %Instance{player: player} = state) do
    {:reply, player, state}
  end

  def handle_cast(:stop, state) do
    {:stop, :normal, state}
  end

  def handle_cast(:invalidate, %Instance{player_module: player_module, player: player} = state) do
    player_module.invalidate(player)
    {:noreply, state}
  end

  def handle_cast({:ready, session_state}, state) do
    handle_update(session_state, state)
  end

  def handle_cast({:update, struct, gateway}, state) do
    state = %{state | gateway: gateway}
    handle_update(struct, state)
  end

  def handle_info({:EXIT, player, _reason}, %Instance{player: player} = state) do
    {:noreply, state} = handle_continue(:start_player, state)
    {:noreply, state, @ready_player}
  end

  def handle_info({:EXIT, session, reason}, %Instance{session: session} = state)
      when reason not in [:normal, :killed] do
    {:noreply, state, @start_session}
  end

  def handle_info(_message, state) do
    {:noreply, state}
  end

  defp handle_update(%VoiceState{channel_id: channel_id, session_id: session_id}, state) do
    state = %{state | channel_id: channel_id, session_id: session_id}
    {:noreply, state, @start_session}
  end

  defp handle_update(%VoiceServerUpdate{endpoint: endpoint, token: token}, state) do
    [host, port] = String.split(endpoint, ":")
    endpoint_host = :binary.bin_to_list(host)
    endpoint_port = String.to_integer(port)

    state = %{state | endpoint_host: endpoint_host, endpoint_port: endpoint_port, token: token}
    {:noreply, state, @start_session}
  end

  defp handle_update(
         %Session{
           udp_socket: udp_socket,
           audio_ip: audio_ip,
           audio_port: audio_port,
           ssrc: ssrc,
           secret_key: secret_key
         },
         state
       ) do
    audio = %Audio{
      udp_socket: udp_socket,
      ip: audio_ip,
      port: audio_port,
      ssrc: ssrc,
      secret_key: secret_key
    }

    state = %{state | audio_struct: audio}
    {:noreply, state, @ready_player}
  end
end
