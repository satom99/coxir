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
    :porcelain,
    {:paused?, false},
    :processor
  ]

  def ready(player, audio) do
    GenServer.cast(player, {:ready, audio})
  end

  def invalidate(player) do
    GenServer.cast(player, :invalidate)
  end

  def play(player, url, _options) do
    GenServer.cast(player, {:play, url})
  end

  def pause(player) do
    GenServer.cast(player, :pause)
  end

  def resume(player) do
    GenServer.cast(player, :resume)
  end

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  def init(_state) do
    Process.flag(:trap_exit, true)
    {:ok, %Default{}}
  end

  def handle_cast({:ready, audio}, state) do
    state = %{state | audio: audio}
    state = update_processor(state)
    {:noreply, state}
  end

  def handle_cast(:invalidate, state) do
    state = %{state | audio: nil}
    state = update_processor(state)
    {:noreply, state}
  end

  def handle_cast(:pause, %Default{paused?: true} = state) do
    {:noreply, state}
  end

  def handle_cast(:pause, state) do
    state = %{state | paused?: true}
    state = update_processor(state)
    {:noreply, state}
  end

  def handle_cast(:resume, %Default{paused?: false} = state) do
    {:noreply, state}
  end

  def handle_cast(:resume, state) do
    state = %{state | paused?: false}
    state = update_processor(state)
    {:noreply, state}
  end

  def handle_cast({:play, url}, %Default{porcelain: nil} = state) do
    options = [
      ["-i", url],
      ["-ac", "2"],
      ["-ar", "48000"],
      ["-f", "s16le"],
      ["-acodec", "libopus"],
      ["-loglevel", "quiet"],
      ["pipe:1"]
    ]

    porcelain =
      %Proc{} =
      Porcelain.spawn(
        Application.get_env(:coxir, :ffmpeg, "ffmpeg"),
        List.flatten(options),
        in: <<>>,
        out: :stream
      )

    state = %{state | porcelain: porcelain, paused?: false}
    state = update_processor(state)
    {:noreply, state}
  end

  def handle_cast({:play, _url} = call, %Default{porcelain: porcelain} = state) do
    state = %{state | porcelain: nil}
    state = update_processor(state)
    Proc.stop(porcelain)
    handle_cast(call, state)
  end

  def handle_info(
        {:EXIT, processor, _reason},
        %Default{audio: audio, processor: processor} = state
      ) do
    Audio.set_speaking(audio, 0)
    {:noreply, state}
  end

  def handle_info(_message, state) do
    {:noreply, state}
  end

  defp update_processor(%Default{audio: audio, processor: processor} = state)
       when is_pid(processor) do
    Process.exit(processor, :kill)
    Audio.set_speaking(audio, 0)
    state = %{state | processor: nil}
    update_processor(state)
  end

  defp update_processor(%Default{audio: nil} = state) do
    state
  end

  defp update_processor(%Default{porcelain: nil} = state) do
    state
  end

  defp update_processor(%Default{paused?: true} = state) do
    state
  end

  defp update_processor(%Default{audio: audio, processor: nil} = state) do
    Audio.set_speaking(audio, 1)
    {:ok, processor} = Task.start_link(fn -> processor_loop(state) end)
    %{state | processor: processor}
  end

  defp processor_loop(%Default{audio: audio, porcelain: porcelain} = state) do
    %Proc{out: source} = porcelain

    {audio, ended?, sleep} = Audio.process_burst(audio, source)

    Process.sleep(sleep)

    state = %{state | audio: audio}

    unless ended?, do: processor_loop(state)
  end
end
