defmodule Coxir.Voice.Manager do
  @moduledoc """
  Work in progress.
  """
  use GenServer

  alias Coxir.VoiceState
  alias Coxir.Gateway.Payload.VoiceServerUpdate
  alias Coxir.Voice.{Instance, Session}
  alias __MODULE__

  @start_session {:continue, :start_session}

  defstruct [
    :instance,
    :udp_socket,
    :user_id,
    :guild_id,
    :channel_id,
    :session_id,
    :endpoint,
    :token
  ]

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

  def handle_continue(:start_session, %Manager{session_id: nil} = state) do
    {:noreply, state}
  end

  def handle_continue(:start_session, %Manager{token: nil} = state) do
    {:noreply, state}
  end

  def handle_continue(:start_session, state) do
    %Manager{
      instance: instance,
      udp_socket: udp_socket,
      user_id: user_id,
      guild_id: guild_id,
      channel_id: channel_id,
      session_id: session_id,
      endpoint: endpoint,
      token: token
    } = state

    session_options = %Session{
      manager: self(),
      udp_socket: udp_socket,
      user_id: user_id,
      guild_id: guild_id,
      channel_id: channel_id,
      session_id: session_id,
      endpoint: endpoint,
      token: token
    }

    Instance.start_session(instance, session_options)

    {:noreply, state}
  end
end
