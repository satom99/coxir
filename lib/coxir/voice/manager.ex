defmodule Coxir.Voice.Manager do
  @moduledoc """
  Work in progress.
  """
  use GenServer

  alias Coxir.VoiceState
  alias Coxir.Gateway.Payload.VoiceServerUpdate

  defstruct [
    :instance,
    :guild_id,
    :channel_id,
    :user_id,
    :token,
    :endpoint
  ]

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:update, struct}, _from, state) do
    handle_update(struct, state)
  end

  defp handle_update(%VoiceState{} = _voice_state, state) do
    {:noreply, state}
  end

  defp handle_update(%VoiceServerUpdate{} = _voice_server_update, state) do
    {:noreply, state}
  end
end
