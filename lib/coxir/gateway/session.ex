defmodule Coxir.Gateway.Session do
  @moduledoc """
  Work in progress.
  """
  use GenServer

  alias __MODULE__

  defstruct [
    :token,
    :shard,
    {:host, 'gateway.discord.gg'},
    :gun_pid,
    :stream_ref,
    :zlib_context
  ]

  @query "/?v=8&encoding=etf&compress=zlib-stream"
  @timeout 10_000

  @connect {:continue, :connect}
  @identify {:continue, :identify}

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  def init(state) do
    {:ok, state, @connect}
  end

  def handle_continue(:connect, %Session{host: host} = state) do
    {:ok, gun_pid} = :gun.open(host, 443, %{protocols: [:http]})
    {:ok, _protocol} = :gun.await_up(gun_pid, @timeout)
    stream_ref = :gun.ws_upgrade(gun_pid, @query)

    state = %{state | gun_pid: gun_pid, stream_ref: stream_ref}
    {:noreply, state}
  end

  def handle_continue(:identify, %Session{token: _token} = state) do
    {:noreply, state}
  end

  def handle_frame({:binary, frame}, %Session{zlib_context: zlib_context} = state) do
    %{op: op, d: data, s: sequence, t: event} =
      zlib_context
      |> :zlib.inflate(frame)
      |> :erlang.iolist_to_binary()
      |> :erlang.binary_to_term()

    payload = {op, data, sequence, event}
    handle_payload(payload, state)
  end

  def handle_frame({:close, _status, _reason}, state) do
    {:stop, :close, state}
  end

  def handle_payload({10, _data, _sequence, _event}, state) do
    {:noreply, state, @identify}
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
    {:stop, :gun_down, state}
  end
end
