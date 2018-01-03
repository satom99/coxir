defmodule Coxir.Voice.Handler do
  @moduledoc false

  use GenServer

  alias Coxir.Voice
  alias Coxir.Voice.{Server, Gateway, Audio}

  #{
  #  :server_id,
  #  :client_id,
  #  :server,
  #  :token,
  #  :endpoint,
  #  :channel_id,
  #  :session_id,
  #  :user_id
  #}
  def start_link(state) do
    GenServer.start_link __MODULE__, state
  end

  def handle_info({:update, data}, state) do
    state = data
    |> handle(state)
    |> control

    {:noreply, state}
  end

  defp handle(%{user_id: user} = data, state) do
    cond do
      user == state.client_id ->
        cond do
          !data.channel_id ->
            state.server_id
            |> Voice.stop
          true ->
            :ok
        end
        Map.merge(state, data)
      true ->
        state
    end
  end

  defp handle(%{secret_key: secret} = data, state) do
    secret = secret
    |> :erlang.list_to_binary

    state.server
    |> Server.get_audio
    |> case do
      nil ->
        data = %{
          udp: data.udp,
          ssrc: data.ssrc,
          port: data.port,
          ip: data.ip,
          secret: secret,
          server: state.server
        }
        state.server
        |> Server.start_child(Audio, data)
      _pid -> :ok
    end
    state
  end

  defp handle(data, state), do: Map.merge(state, data)

  defp control(%{token: token, session_id: session_id} = state) do
    state.server
    |> Server.get_gateway
    |> case do
      nil ->
        data = %{
          token: token,
          endpoint: state.endpoint,
          server_id: state.server_id,
          channel_id: state.channel_id,
          session_id: session_id,
          user_id: state.user_id,
          handler: self()
        }
        state.server
        |> Server.start_child(Gateway, data)
      _pid -> :ok
    end
    state
  end
  defp control(state), do: state
end
