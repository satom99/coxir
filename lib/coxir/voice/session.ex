defmodule Coxir.Voice.Session do
  @moduledoc """
  Work in progress.
  """
  use GenServer

  alias __MODULE__

  defstruct [
    :guild_id,
    :channel_id,
    :session_id,
    :endpoint,
    :token,
    :gun_pid,
    :stream_ref,
    :heartbeat_ref
  ]

  @query "/?v=4"

  @connect {:continue, :connect}
  @reconnect {:continue, :reconnect}

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  def init(state) do
    {:ok, state, @connect}
  end

  def handle_continue(:connect, %Session{endpoint: endpoint} = state) do
    {:ok, gun_pid} = :gun.open(endpoint, 443, %{protocols: [:http]})
    state = %{state | gun_pid: gun_pid}
    {:noreply, state}
  end

  def handle_continue(
        :reconnect,
        %Session{gun_pid: gun_pid, heartbeat_ref: heartbeat_ref} = state
      ) do
    :ok = :gun.close(gun_pid)
    :timer.cancel(heartbeat_ref)

    {:noreply, state, @connect}
  end

  def handle_frame({:binary, _frame}, state) do
    {:noreply, state}
  end

  def handle_frame({:close, _status, _reason}, state) do
    {:noreply, state, @reconnect}
  end

  def handle_info({:gun_up, gun_pid, :http}, %Session{gun_pid: gun_pid} = state) do
    stream_ref = :gun.ws_upgrade(gun_pid, @query)
    state = %{state | stream_ref: stream_ref}
    {:noreply, state}
  end

  def handle_info(
        {:gun_upgrade, gun_pid, stream_ref, ["websocket"], _headers},
        %Session{gun_pid: gun_pid, stream_ref: stream_ref} = state
      ) do
    {:noreply, state}
  end

  def handle_info(
        {:gun_ws, gun_pid, stream_ref, frame},
        %Session{gun_pid: gun_pid, stream_ref: stream_ref} = state
      ) do
    handle_frame(frame, state)
  end

  def handle_info(
        {:gun_response, gun_pid, stream_ref, _is_fin, _status, _headers},
        %Session{gun_pid: gun_pid, stream_ref: stream_ref} = state
      ) do
    {:noreply, state, @reconnect}
  end

  def handle_info(
        {:gun_error, gun_pid, stream_ref, _reason},
        %Session{gun_pid: gun_pid, stream_ref: stream_ref} = state
      ) do
    {:noreply, state, @reconnect}
  end

  def handle_info(
        {:gun_down, gun_pid, _protocol, _reason, _killed, _unprocessed},
        %Session{gun_pid: gun_pid} = state
      ) do
    {:noreply, state, @reconnect}
  end
end
