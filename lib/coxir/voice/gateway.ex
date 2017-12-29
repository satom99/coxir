defmodule Coxir.Voice.Gateway do
  @moduledoc false

  use WebSockex

  alias Coxir.Voice
  alias Coxir.Voice.{UDP}

  #{
  #  :token,
  #  :endpoint,
  #  :server_id,
  #  :session_id,
  #  :user_id,
  #  :handler,
  #
  #  :udp,
  #  :ip,
  #  :port,
  #  :ssrc,
  #
  #  :mode,
  #  :secret_key
  #}
  def start_link(state) do
    endpoint = state.endpoint
    |> String.replace(":80", "")
    endpoint = "wss://#{endpoint}/?v=3"

    WebSockex.start_link(endpoint, __MODULE__, state)
  end

  def handle_disconnect(%{reason: reason}, state) do
    reason
    |> elem(1)
    |> case do
      4014 -> :ok
      4015 -> :ok
      _err -> Voice.leave(state.server_id)
    end
    {:ok, state}
  end

  def handle_connect(_connection, state) do
    send(self(), :identify)
    {:ok, state}
  end

  def handle_info(:identify, state) do
    data = %{
      token: state.token,
      user_id: state.user_id,
      server_id: state.server_id,
      session_id: state.session_id
    }
    |> payload(0)

    {:reply, {:text, data}, state}
  end
  def handle_info(:heartbeat, state) do
    data = DateTime.utc_now
    |> DateTime.to_unix
    |> payload(3)

    {:reply, {:text, data}, state}
  end
  def handle_info({:speaking, bool}, state) do
    data = %{
      delay: 0,
      speaking: bool
    }
    |> payload(5)

    {:reply, {:text, data}, state}
  end
  def handle_info(_event, state), do: {:ok, state}

  def handle_frame({:text, data}, state) do
    data
    |> parse
    |> dispatch(state)
  end
  def handle_frame(_frame, state), do: {:ok, state}

  def dispatch(%{op: 8, d: data}, state) do
    interval = data.heartbeat_interval * 0.75
    |> Kernel.trunc

    :timer.send_interval(
      interval,
      :heartbeat
    )
    {:ok, state}
  end

  def dispatch(%{op: 2, d: data}, state) do
    {udp, remote, local, port} = UDP.open(
      data.ip,
      data.port,
      data.ssrc
    )

    state = state
    |> Map.merge %{
      udp: udp,
      ip: remote,
      port: data.port,
      ssrc: data.ssrc
    }

    data = %{
      protocol: "udp",
      data: %{
        port: port,
        address: local,
        mode: "xsalsa20_poly1305"
      }
    }
    |> payload(1)

    {:reply, {:text, data}, state}
  end

  def dispatch(%{op: 4, d: data}, state) do
    state = state
    |> Map.merge(data)

    data = data
    |> Map.merge %{
      udp: state.udp,
      ssrc: state.ssrc,
      port: state.port,
      ip: state.ip
    }

    state.handler
    |> send({:update, data})

    {:ok, state}
  end

  def dispatch(_data, state), do: {:ok, state}

  defp parse(term) do
    term
    |> Jason.decode!(keys: :atoms)
  end

  defp encode(term) do
    term
    |> Jason.encode!
  end

  defp payload(data, op) do
    %{op: op, d: data}
    |> encode
  end
end
