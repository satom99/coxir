defmodule Coxir.Voice.Manager do
  @moduledoc """
  Work in progress.
  """
  use GenServer

  alias Coxir.VoiceState
  alias Coxir.Gateway.Payload.VoiceServerUpdate
  alias Coxir.Voice.Instance

  @start_session {:continue, :start_session}

  def update(manager, struct) do
    GenServer.call(manager, {:update, struct})
  end

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:update, struct}, _from, state) do
    handle_update(struct, state)
  end

  defp handle_update(%VoiceState{session_id: session_id}, state) do
    state = %{state | session_id: session_id}
    {:noreply, state, @start_session}
  end

  defp handle_update(%VoiceServerUpdate{token: token, endpoint: endpoint}, state) do
    state = %{state | token: token, endpoint: endpoint}
    {:noreply, state, @start_session}
  end

  def handle_continue(:start_session, %Instance{session_id: nil} = state) do
    {:noreply, state}
  end

  def handle_continue(:start_session, %Instance{token: nil} = state) do
    {:noreply, state}
  end

  def handle_continue(:start_session, %Instance{instance: instance} = state) do
    Instance.start_session(instance, state)
    {:noreply, state}
  end
end
