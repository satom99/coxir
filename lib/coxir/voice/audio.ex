defmodule Coxir.Voice.Audio do
  @moduledoc false

  use GenServer

  alias Coxir.Voice.Server

  #{
  #  :udp,
  #  :ssrc,
  #  :port,
  #  :ip,
  #  :secret,
  #  :server,
  #  :player,
  #  :sequence,
  #  :timestamp
  #}
  def start_link(state) do
    state = state
    |> Map.merge %{
      player: nil,
      sequence: 0,
      timestamp: 0
    }
    GenServer.start_link __MODULE__, state
  end

  def init(state) do
    Process.flag(:trap_exit, true)
    {:ok, state}
  end

  def play(pid, term) do
    pid
    |> GenServer.call {:play, term}
  end
  def stop(pid) do
    pid
    |> GenServer.call :stop
  end

  def handle_call({:play, term}, _from, state) do
    state.player
    |> case do
      nil ->
        audio = self()
        {:ok, pid} = \
        Task.start_link(
          fn ->
            state = state
            |> Map.merge %{
              audio: audio
            }
            do_player(term, state)
          end
        )

        state = state
        |> Map.put(:player, pid)

        {:reply, :ok, state}
      _pid ->
        {:reply, :error, state}
    end
  end

  def handle_call(:stop, _from, state) do
    state.player
    |> case do
      nil -> :ok
      pid ->
        pid
        |> Process.exit(:kill)
    end
    {:reply, :ok, state}
  end

  # Player
  def do_player(term, state) do
    cond do
      is_binary(term) ->
        file_stream(term)
      true ->
        io_stream(term)
    end
    |> do_stream(state)
  end

  def handle_info({:send, frame}, state) do
    frame = frame
    |> encode(state)
    :gen_udp.send(state.udp, state.ip, state.port, frame)

    state = state
    |> Map.update!(:sequence, & &1 + 1)
    |> Map.update!(:timestamp, & &1 + 960)

    {:noreply, state}
  end

  def handle_info({:EXIT, _from, _reason}, state) do
    for _index <- 1..5 do
      <<0xF8, 0xFF, 0xFE>>
      |> send_frame(state)
      Process.sleep(20)
    end
    speaking(state, false)

    state = state
    |> Map.put(:player, nil)

    {:noreply, state}
  end

  defp do_stream(data, state) do
    speaking(state, true)

    data
    |> Enum.reduce(
      nil,
      fn frame, elapsed ->
        send_frame(frame, state)

        now = :os.system_time(:milli_seconds)
        elapsed = elapsed || now
        elapsed - now + 20
        |> max(0)
        |> Process.sleep

        elapsed + 20
      end
    )
  end

  defp speaking(state, bool) do
    state.server
    |> Server.get_gateway
    |> send({:speaking, bool})
  end

  defp send_frame(frame, state) do
    state
    |> Map.get(:audio)
    |> case do
      nil -> self()
      pid -> pid
    end
    |> send({:send, frame})
  end

  # Audio
  defp io_stream(data) do
    "pipe:0"
    |> ffmpeg(in: data)
    |> Map.get(:out)
  end

  defp file_stream(path) do
    path
    |> ffmpeg
    |> Map.get(:out)
  end

  defp header(sequence, time, ssrc) do
    <<0x80, 0x78, sequence::size(16),
      time::size(32), ssrc::size(32)>>
  end

  defp encode(frame, state) do
    head = header(state.sequence, state.timestamp, state.ssrc)
    nonce = head <> <<0::size(96)>>
    head <> Kcl.secretbox(frame, nonce, state.secret)
  end

  defp ffmpeg(input, options \\ []) do
    exec = Application.fetch_env!(:coxir, :ffmpeg)
    Porcelain.spawn(
      exec,
      [
        "-i", input,
        "-ac", "2",
        "-ar", "48k",
        "-f", "s16le",
        "-acodec", "libopus",
        "-loglevel", "quiet",
        "pipe:1"
      ],
      options ++ [out: :stream]
    )
  end
end
