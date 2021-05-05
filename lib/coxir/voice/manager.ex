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
    GenServer.cast(manager, {:update, struct})
  end

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  def init(state) do
    state = %{state | manager: self()}
    {:ok, state}
  end

  def handle_cast({:update, struct}, state) do
    handle_update(struct, state)
  end

  defp handle_update(%VoiceState{channel_id: channel_id, session_id: session_id}, state) do
    state = %{state | channel_id: channel_id, session_id: session_id}
    {:noreply, state, @start_session}
  end

  defp handle_update(%VoiceServerUpdate{token: token, endpoint: endpoint}, state) do
    [host, port] = String.split(endpoint, ":")
    endpoint_host = :binary.bin_to_list(host)
    endpoint_port = String.to_integer(port)

    state = %{state | token: token, endpoint_host: endpoint_host, endpoint_port: endpoint_port}
    {:noreply, state, @start_session}
  end

  defp handle_update(
         %Instance{session_id: session_id} = new_state,
         %Instance{session_id: session_id} = _state
       ) do
    {:noreply, new_state}
  end

  defp handle_update(%Instance{} = _obsolete, state) do
    {:noreply, state}
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
