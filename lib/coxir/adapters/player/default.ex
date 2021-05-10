defmodule Coxir.Player.Default do
  @moduledoc """
  Pipes audio from ffmpeg.
  """
  @behaviour Coxir.Player

  use GenServer

  alias Porcelain.Process, as: Proc
  alias Coxir.Voice.Audio
  alias __MODULE__

  @type playable :: String.t()

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

  def pause(player) do
    GenServer.call(player, :pause)
  end

  def resume(player) do
    GenServer.call(player, :resume)
  end

  def playing?(player) do
    GenServer.call(player, :playing?)
  end

  def start_link(start) do
    GenServer.start_link(__MODULE__, start)
  end

  def init({url, _options}) do
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

    state = %Default{process: process}
    {:ok, state}
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

  def handle_call(:pause, _from, state) do
    state = %{state | paused?: true}
    state = update_playback(state)
    {:reply, :ok, state}
  end

  def handle_call(:resume, _from, state) do
    state = %{state | paused?: false}
    state = update_playback(state)
    {:reply, :ok, state}
  end

  def handle_call(:playing?, _from, %Default{paused?: paused?} = state) do
    {:reply, not paused?, state}
  end

  def handle_info({ref, :ended}, %Default{audio: audio, playback: %Task{ref: ref}} = state) do
    Audio.stop_speaking(audio)
    {:stop, :normal, state}
  end

  def handle_info({ref, _reason}, %Default{audio: audio, playback: %Task{ref: ref}} = state) do
    Audio.stop_speaking(audio)
    state = %{state | playback: nil}
    state = update_playback(state)
    {:noreply, state}
  end

  def handle_info(_message, state) do
    {:noreply, state}
  end

  defp update_playback(%Default{playback: playback} = state) when not is_nil(playback) do
    Task.shutdown(playback)
    state = %{state | playback: nil}
    update_playback(state)
  end

  defp update_playback(%Default{audio: nil} = state) do
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

    playback = Task.async(starter)

    %{state | playback: playback}
  end

  defp playback_loop(%Default{audio: audio, process: process} = state) do
    %Proc{out: source} = process

    {audio, ended?, sleep} = Audio.process_burst(audio, source)

    if not ended? do
      Process.sleep(sleep)
      state = %{state | audio: audio}
      playback_loop(state)
    else
      :ended
    end
  end
end
