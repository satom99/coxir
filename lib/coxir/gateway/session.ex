defmodule Coxir.Gateway.Session do
  @moduledoc """
  Work in progress.
  """
  use GenServer

  alias Coxir.Gateway.{Payload, Producer}
  alias Coxir.Gateway.Payload.{Hello, Identify, Resume}
  alias __MODULE__

  defstruct [
    :token,
    :shard,
    :intents,
    :gateway,
    :producer,
    :gun_pid,
    :stream_ref,
    :zlib_context,
    :heartbeat_ref,
    :heartbeat_ack,
    :sequence,
    :session_id
  ]

  @query "/?v=8&encoding=json&compress=zlib-stream"
  @timeout 10_000

  @connect {:continue, :connect}
  @reconnect {:continue, :reconnect}
  @identify {:continue, :identify}

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  def init(state) do
    {:ok, state, @connect}
  end

  def handle_continue(:connect, %Session{gateway: gateway} = state) do
    {:ok, gun_pid} = :gun.open(gateway, 443, %{protocols: [:http]})
    {:ok, :http} = :gun.await_up(gun_pid, @timeout)
    stream_ref = :gun.ws_upgrade(gun_pid, @query)

    state = %{state | gun_pid: gun_pid, stream_ref: stream_ref}
    {:noreply, state}
  end

  def handle_continue(
        :reconnect,
        %Session{gun_pid: gun_pid, zlib_context: zlib_context, heartbeat_ref: heartbeat_ref} =
          state
      ) do
    :ok = :gun.close(gun_pid)
    :ok = :zlib.inflateReset(zlib_context)
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
      compress: true,
      properties: %{
        :"$browser" => "coxir",
        :"$device" => "coxir"
      }
    }

    send_payload(:IDENTIFY, identify, state)

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

    send_payload(:RESUME, resume, state)

    {:noreply, state}
  end

  def handle_frame({:binary, frame}, %Session{zlib_context: zlib_context} = state) do
    zlib_context
    |> :zlib.inflate(frame)
    |> Jason.decode!()
    |> Payload.cast()
    |> handle_payload(state)
  end

  def handle_frame({:close, _status, _reason}, state) do
    {:stop, :close, state}
  end

  def handle_payload(%Payload{operation: :HELLO, data: data}, state) do
    %Hello{heartbeat_interval: heartbeat_interval} = Hello.cast(data)

    heartbeat_ref = :timer.send_interval(heartbeat_interval, self(), :heartbeat)

    state = %{state | heartbeat_ref: heartbeat_ref, heartbeat_ack: true}
    {:noreply, state, @identify}
  end

  def handle_payload(
        %Payload{operation: :DISPATCH, data: data, sequence: sequence} = payload,
        %Session{producer: producer, session_id: session_id} = state
      ) do
    Producer.notify(producer, payload)

    session_id = Map.get(data, "session_id", session_id)
    state = %{state | session_id: session_id, sequence: sequence}
    {:noreply, state}
  end

  def handle_payload(%Payload{operation: :HEARTBEAT_ACK}, state) do
    state = %{state | heartbeat_ack: true}
    {:noreply, state}
  end

  def handle_info(:heartbeat, %Session{sequence: sequence, heartbeat_ack: true} = state) do
    send_payload(:HEARTBEAT, sequence, state)
    state = %{state | heartbeat_ack: false}
    {:noreply, state}
  end

  def handle_info(:heartbeat, %Session{heartbeat_ack: false} = state) do
    {:noreply, state, @reconnect}
  end

  def handle_info(
        {:gun_upgrade, gun_pid, stream_ref, ["websocket"], _headers},
        %Session{gun_pid: gun_pid, stream_ref: stream_ref} = state
      ) do
    zlib_context = :zlib.open()
    :zlib.inflateInit(zlib_context)

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
    {:stop, :gun_response, state}
  end

  def handle_info(
        {:gun_error, gun_pid, stream_ref, _reason},
        %Session{gun_pid: gun_pid, stream_ref: stream_ref} = state
      ) do
    {:stop, :gun_error, state}
  end

  def handle_info(
        {:gun_down, gun_pid, _protocol, _reason, _killed, _unprocessed},
        %Session{gun_pid: gun_pid} = state
      ) do
    {:noreply, state, @reconnect}
  end

  defp send_payload(operation, data, %Session{gun_pid: gun_pid}) do
    payload = %Payload{operation: operation, data: data}
    object = Payload.extract(payload)
    binary = Jason.encode!(object)
    message = {:binary, binary}

    :ok = :gun.ws_send(gun_pid, message)
  end
end
