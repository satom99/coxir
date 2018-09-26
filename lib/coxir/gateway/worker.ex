defmodule Coxir.Gateway.Worker do
  @moduledoc false

  use WebSockex

  alias Coxir.Stage.Producer

  def start_link(state) do
    state = state
    |> Map.merge(
      %{
        beat: nil,
        session: nil,
        sequence: nil
      }
    )
    WebSockex.start_link(state.gateway, __MODULE__, state)
  end

  def handle_disconnect(%{reason: _reason}, state) do
    :timer.cancel(state.beat)
    {:reconnect, %{state | beat: nil}}
  end

  def handle_info(:heartbeat, state) do
    data = state.sequence
    |> payload(1)
    {:reply, {:text, data}, state}
  end
  def handle_info({:send, opcode, data}, state) do
    data = data
    |> payload(opcode)
    {:reply, {:text, data}, state}
  end
  def handle_info(_event, state), do: {:ok, state}

  def handle_frame({:text, data}, state) do
    data
    |> parse
    |> dispatch(state)
  end
  def handle_frame({:binary, data}, state) do
    data
    |> :zlib.uncompress
    |> parse
    |> dispatch(state)
  end
  def handle_frame(_frame, state), do: {:ok, state}

  def dispatch(%{op: 10, d: data}, state) do
    state = \
    case state.beat do
      nil ->
        beat = :timer.send_interval(
          data.heartbeat_interval,
          :heartbeat
        )
        %{state | beat: beat}
      _other ->
        state
    end

    data = \
    case state.session do
      nil ->
        {family, _name} = :os.type
        %{
          token: state.token,
          properties: %{
            "$os": family,
            "$device": "coxir",
            "$browser": "coxir"
          },
          compress: true,
          large_threshold: 250,
          shard: state.shard
        }
        |> payload(2)
      session ->
        %{
          token: state.token,
          session_id: session,
          seq: state.sequence
        }
        |> payload(6)
    end

    {:reply, {:text, data}, state}
  end

  def dispatch(%{op: 7}, state) do
    {:close, state}
  end

  def dispatch(%{op: 9}, state) do
    {:close, %{state | session: nil}}
  end

  def dispatch(%{op: 1}, state) do
    handle_info(:heartbeat, state)
  end

  def dispatch(%{op: 0, t: name, d: data, s: sequence}, state) do
    Producer.notify %{
      t: String.to_atom(name),
      d: data
    }
    {:ok, %{state | sequence: sequence}}
  end

  def dispatch(_data, state), do: {:ok, state}

  defp parse(term) do
    term
    |> Poison.decode!(keys: :atoms)
  end

  defp encode(term) do
    term
    |> Poison.encode!
  end

  defp payload(data, op) do
    %{op: op, d: data}
    |> encode
  end
end
