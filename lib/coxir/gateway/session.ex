defmodule Coxir.Gateway.Session do
  @moduledoc """
  Work in progress.
  """
  use GenServer

  alias Coxir.Gateway.{Payload, Producer}
  alias Coxir.Gateway.Payload.{Hello, Identify, Resume}
  alias Coxir.Gateway.Payload.{UpdatePresence, UpdateVoiceState}
  alias __MODULE__

  defstruct [
    :shard,
    :token,
    :user_id,
    :intents,
    :producer,
    :gateway_host,
    :gun_pid,
    :stream_ref,
    :zlib_context,
    :heartbeat_ref,
    :heartbeat_ack,
    :sequence,
    :session_id
  ]

  @query "/?v=8&encoding=json&compress=zlib-stream"

  @close_raise [4010, 4011, 4014]
  @close_session [4007, 4009]

  @connect {:continue, :connect}
  @reconnect {:continue, :reconnect}
  @identify {:continue, :identify}

  @type session :: pid

  def update_presence(session, %UpdatePresence{} = payload) do
    GenServer.call(session, {:send_command, :PRESENCE_UPDATE, payload})
  end

  def update_voice_state(session, %UpdateVoiceState{} = payload) do
    GenServer.call(session, {:send_command, :VOICE_STATE_UPDATE, payload})
  end

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  def init(state) do
    {:ok, state, @connect}
  end

  def handle_continue(:connect, %Session{gateway_host: gateway_host} = state) do
    {:ok, gun_pid} = :gun.open(gateway_host, 443, %{protocols: [:http]})
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
        %Session{session_id: nil, token: token, shard: shard, intents: intents} = state
      ) do
    identify = %Identify{
      token: token,
      shard: shard,
      intents: intents,
      compress: true
    }

    send_command(:IDENTIFY, identify, state)

    {:noreply, state}
  end

  def handle_continue(
        :identify,
        %Session{session_id: session_id, token: token, sequence: sequence} = state
      ) do
    resume = %Resume{
      token: token,
      session_id: session_id,
      sequence: sequence
    }

    send_command(:RESUME, resume, state)

    {:noreply, state}
  end

  def handle_call({:send_command, operation, data}, _from, state) do
    result = send_command(operation, data, state)
    {:reply, result, state}
  end

  def handle_info(:heartbeat, %Session{sequence: sequence, heartbeat_ack: true} = state) do
    send_command(:HEARTBEAT, sequence, state)
    state = %{state | heartbeat_ack: false}
    {:noreply, state}
  end

  def handle_info(:heartbeat, %Session{heartbeat_ack: false} = state) do
    {:noreply, state, @reconnect}
  end

  def handle_info({:gun_up, gun_pid, :http}, %Session{gun_pid: gun_pid} = state) do
    stream_ref = :gun.ws_upgrade(gun_pid, @query)
    state = %{state | stream_ref: stream_ref}
    {:noreply, state}
  end

  def handle_info(
        {:gun_upgrade, gun_pid, stream_ref, ["websocket"], _headers},
        %Session{gun_pid: gun_pid, stream_ref: stream_ref, zlib_context: zlib_context} = state
      ) do
    zlib_context =
      if is_nil(zlib_context) do
        zlib_context = :zlib.open()
        :zlib.inflateInit(zlib_context)
        zlib_context
      else
        :zlib.inflateReset(zlib_context)
        zlib_context
      end

    state = %{state | zlib_context: zlib_context}
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

  defp handle_frame(
         {:binary, frame},
         %Session{zlib_context: zlib_context, user_id: user_id} = state
       ) do
    zlib_context
    |> :zlib.inflate(frame)
    |> Jason.decode!()
    |> Payload.cast(user_id, self())
    |> handle_payload(state)
  end

  defp handle_frame({:close, status, reason}, _state) when status in @close_raise do
    raise(reason)
  end

  defp handle_frame({:close, status, _reason}, state) when status in @close_session do
    state = %{state | session_id: nil}
    {:noreply, state, @reconnect}
  end

  defp handle_frame({:close, _status, _reason}, state) do
    {:noreply, state, @reconnect}
  end

  defp handle_payload(%Payload{operation: :HELLO, data: data}, state) do
    %Hello{heartbeat_interval: heartbeat_interval} = Hello.cast(data)

    heartbeat_ref = :timer.send_interval(heartbeat_interval, self(), :heartbeat)

    state = %{state | heartbeat_ref: heartbeat_ref, heartbeat_ack: true}
    {:noreply, state, @identify}
  end

  defp handle_payload(%Payload{operation: :RECONNECT}, state) do
    {:noreply, state, @reconnect}
  end

  defp handle_payload(%Payload{operation: :INVALID_SESSION}, state) do
    state = %{state | session_id: nil}
    {:noreply, state, @identify}
  end

  defp handle_payload(
         %Payload{operation: :DISPATCH, data: data, sequence: sequence} = payload,
         %Session{producer: producer, session_id: session_id} = state
       ) do
    Producer.notify(producer, payload)

    session_id = Map.get(data, "session_id", session_id)
    state = %{state | session_id: session_id, sequence: sequence}
    {:noreply, state}
  end

  defp handle_payload(%Payload{operation: :HEARTBEAT_ACK}, state) do
    state = %{state | heartbeat_ack: true}
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
