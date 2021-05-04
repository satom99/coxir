defmodule Coxir.Voice.Session do
  @moduledoc """
  Work in progress.
  """
  use GenServer

  alias Coxir.Voice.Payload
  alias Coxir.Voice.Payload.{Hello, Identify}
  alias __MODULE__

  defstruct [
    :manager,
    :user_id,
    :guild_id,
    :channel_id,
    :session_id,
    :endpoint,
    :token,
    :gun_pid,
    :stream_ref,
    :heartbeat_ref,
    :heartbeat_nonce,
    :heartbeat_ack
  ]

  @query "/?v=4"

  @connect {:continue, :connect}
  @reconnect {:continue, :reconnect}
  @identify {:continue, :identify}

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

  def handle_continue(
        :identify,
        %Session{user_id: user_id, guild_id: guild_id, session_id: session_id, token: token} =
          state
      ) do
    identify = %Identify{
      user_id: user_id,
      server_id: guild_id,
      session_id: session_id,
      token: token
    }

    send_command(:IDENTIFY, identify, state)

    {:noreply, state}
  end

  def handle_frame({:binary, frame}, state) do
    frame
    |> Jason.decode!()
    |> Payload.cast()
    |> handle_payload(state)
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

  def handle_info(:heartbeat, %Session{heartbeat_ack: true} = state) do
    heartbeat_nonce = System.unique_integer()
    send_command(:HEARTBEAT, heartbeat_nonce, state)
    state = %{state | heartbeat_nonce: heartbeat_nonce, heartbeat_ack: false}
    {:noreply, state}
  end

  def handle_info(:heartbeat, %Session{heartbeat_ack: false} = state) do
    {:noreply, state, @reconnect}
  end

  defp handle_payload(%Payload{operation: :HELLO, data: data}, state) do
    %Hello{heartbeat_interval: heartbeat_interval} = Hello.cast(data)

    heartbeat_ref = :timer.send_interval(heartbeat_interval, self(), :heartbeat)

    state = %{state | heartbeat_ref: heartbeat_ref, heartbeat_ack: true}
    {:noreply, state, @identify}
  end

  defp handle_payload(
         %Payload{operation: :HEARTBEAT_ACK, data: nonce},
         %Session{heartbeat_nonce: nonce} = state
       ) do
    state = %{state | heartbeat_ack: true}
    {:noreply, state}
  end

  defp handle_payload(%Payload{operation: :HEARTBEAT_ACK}, state) do
    {:noreply, state}
  end

  defp send_command(operation, data, %Session{gun_pid: gun_pid}) do
    payload = %Payload{operation: operation, data: data}
    command = Payload.to_command(payload)
    binary = Jason.encode!(command)
    message = {:binary, binary}

    :ok = :gun.ws_send(gun_pid, message)
  end
end
