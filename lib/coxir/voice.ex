defmodule Coxir.Voice do
  @moduledoc """
  Handles and supervises all the audio
  logic behind voice channels.
  """
  @type channel :: String.t | map

  use Supervisor

  alias Coxir.Gateway
  alias Coxir.Struct.{User, Guild}
  alias Coxir.Voice.{Server, Audio}

  def init(args) do
    {:ok, args}
  end

  @doc false
  def start_link do
    children = []
    options = [
      strategy: :one_for_one,
      name: __MODULE__
    ]
    Supervisor.start_link(children, options)
  end

  @doc false
  def child_spec(arg),
    do: super(arg)

  @doc """
  Joins a given voice channel.

  Always returns a truthy value.
  """
  @spec join(channel) :: any

  def join(%{guild_id: guild, id: id}),
    do: join(guild, id)

  def join(%{id: id}),
    do: join(nil, id)

  @doc false
  def join(guild, channel) do
    guild
    |> get
    |> case do
      nil ->
        state = %{
          server_id: guild,
          client_id: User.get_id()
        }
        child = supervisor(
          Server,
          [state],
          [id: guild]
        )
        __MODULE__
        |> Supervisor.start_child(child)
      _pid -> :ok
    end
    notify(guild, channel)
  end

  @doc """
  Leaves from a given voice channel.

  Always returns a truthy value.
  """
  @spec leave(channel) :: any

  def leave(%{guild_id: guild}),
    do: leave(guild)

  def leave(%{id: _id}),
    do: leave(nil)

  def leave(guild),
    do: notify(guild, nil)

  @doc """
  Plays a term on a given voice channel.

  Returns the atom `:ok` upon success
  or the atom `:error` otherwise.
  """
  @spec play(channel, String.t | Stream.t) :: :ok | :error

  def play(%{guild_id: guild}, term),
    do: play(guild, term)

  def play(%{id: _id}, term),
    do: play(nil, term)

  def play(server, term) do
    server
    |> get_audio
    |> case do
      nil -> :error
      pid -> Audio.play(pid, term)
    end
  end

  @doc """
  Stops sending audio to a given voice channel.

  Always returns a truthy value.
  """
  @spec stop_playing(channel) :: any

  def stop_playing(%{guild_id: guild}),
    do: stop_playing(guild)

  def stop_playing(%{id: _id}),
    do: stop_playing(nil)

  def stop_playing(server) do
    server
    |> get_audio
    |> case do
      nil -> :error
      pid -> Audio.stop(pid)
    end
  end

  @doc false
  def update(server, data) do
    server
    |> Server.update(data)
  end

  @doc false
  def get(server) do
    __MODULE__
    |> Supervisor.which_children
    |> Enum.find(
      fn {id, _pid, _type, _modules} ->
        id == server
      end
    )
    |> case do
      {id, pid, _type, _modules} ->
        case pid do
          :undefined ->
            stop(id)
            nil
          pid -> pid
        end
      _none ->
        nil
    end
  end

  @doc false
  def stop(server) do
    __MODULE__
    |> Supervisor.terminate_child(server)

    __MODULE__
    |> Supervisor.delete_child(server)
  end

  defp notify(guild, channel) do
    (guild || "0")
    |> Guild.shard
    |> Gateway.send(
      4,
      %{
        guild_id: guild,
        channel_id: channel,
        self_mute: false,
        self_deaf: false
      }
    )
  end

  defp get_audio(server) do
    server
    |> get
    |> case do
      nil -> nil
      server ->
        1..8
        |> Enum.reduce(
          nil,
          fn index, pid ->
            cond do
              is_pid(pid) ->
                pid
              true ->
                if index > 1 do
                  Process.sleep(1000)
                end
                Server.get_audio(server)
            end
          end
        )
    end
  end
end
