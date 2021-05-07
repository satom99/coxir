defmodule Coxir.Player.Default do
  @moduledoc """
  Work in progress.
  """
  @behaviour Coxir.Player

  use GenServer

  alias Porcelain.Process, as: Proc
  alias Coxir.Voice.Audio
  alias __MODULE__

  defstruct [
    :audio,
    :process,
    :playback,
    {:paused?, false}
  ]

  def ready(player, audio) do
    GenServer.call(player, {:ready, audio})
  end

  def invalidate(player) do
    GenServer.call(player, :invalidate)
  end

  def play(player, url, options) do
    GenServer.call(player, {:play, url, options})
  end

  def pause(player) do
    GenServer.call(player, :pause)
  end

  def resume(player) do
    GenServer.call(player, :resume)
  end

  def stop_playing(player) do
    GenServer.call(player, :stop_playing)
  end

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  def init(_state) do
    Process.flag(:trap_exit, true)
    {:ok, %Default{}}
  end

  def handle_call({:ready, audio}, _from, state) do
    state = %{state | audio: audio}
    state = update_playback(state)
    {:reply, :ok, state}
  end

  def handle_call(:invalidate, _from, state) do
    state = %{state | audio: nil}
    state = update_playback(state)
    {:reply, :ok, state}
  end

  def handle_call({:play, url, _options}, _from, %Default{process: nil} = state) do
    ffmpeg = Application.get_env(:coxir, :ffmpeg, "ffmpeg")

    options = [
      ["-i", url],
      ["-ac", "2"],
      ["-ar", "48000"],
      ["-f", "s16le"],
      ["-acodec", "libopus"],
      ["-loglevel", "quiet"],
      ["pipe:1"]
    ]

    process =
      %Proc{} =
      Porcelain.spawn(
        ffmpeg,
        List.flatten(options),
        out: :stream
      )

    state = %{state | process: process, paused?: false}
    state = update_playback(state)
    {:reply, :ok, state}
  end

  def handle_call({:play, _url, _options} = call, from, state) do
    state = stop_process(state)
    handle_call(call, from, state)
  end

  def handle_call(:pause, _from, %Default{paused?: true} = state) do
    {:reply, :noop, state}
  end

  def handle_call(:pause, _from, state) do
    state = %{state | paused?: true}
    state = update_playback(state)
    {:reply, :ok, state}
  end

  def handle_call(:resume, _from, %Default{paused?: false} = state) do
    {:reply, :noop, state}
  end

  def handle_call(:resume, _from, state) do
    state = %{state | paused?: false}
    state = update_playback(state)
    {:reply, :ok, state}
  end

  def handle_call(:stop_playing, _from, %Default{process: nil} = state) do
    {:reply, :noop, state}
  end

  def handle_call(:stop_playing, _from, state) do
    state = stop_process(state)
    {:reply, :ok, state}
  end

  def handle_info({:EXIT, playback, _reason}, %Default{audio: audio, playback: playback} = state) do
    Audio.stop_speaking(audio)
    state = %{state | playback: nil}
    state = update_playback(state)
    {:noreply, state}
  end

  def handle_info(_message, state) do
    {:noreply, state}
  end

  defp stop_process(%Default{process: process} = state) do
    state = %{state | process: nil}
    state = update_playback(state)
    Proc.stop(process)
    state
  end

  defp update_playback(%Default{playback: playback} = state) when is_pid(playback) do
    Process.exit(playback, :kill)
    state = %{state | playback: nil}
    update_playback(state)
  end

  defp update_playback(%Default{audio: nil} = state) do
    state
  end

  defp update_playback(%Default{process: nil} = state) do
    state
  end

  defp update_playback(%Default{paused?: true} = state) do
    state
  end

  defp update_playback(%Default{audio: audio} = state) do
    starter = fn ->
      Audio.start_speaking(audio)
      playback_loop(state)
    end

    {:ok, playback} = Task.start_link(starter)

    %{state | playback: playback}
  end

  defp playback_loop(%Default{audio: audio, process: process} = state) do
    %Proc{out: source} = process

    {audio, ended?, sleep} = Audio.process_burst(audio, source)

    Process.sleep(sleep)

    state = %{state | audio: audio}

    unless ended?, do: playback_loop(state)
  end
end
