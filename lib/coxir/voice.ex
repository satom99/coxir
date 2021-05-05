defmodule Coxir.Voice do
  @moduledoc """
  Work in progress.
  """
  use Supervisor

  import Supervisor, only: [start_child: 2]

  alias Coxir.Gateway.Session
  alias Coxir.Gateway.Payload.UpdateVoiceState
  alias Coxir.{Gateway, Channel}
  alias Coxir.Voice.{Instance, Manager}
  alias __MODULE__

  def join(%Channel{id: channel_id, guild_id: guild_id} = channel, options) do
    gateway = Keyword.fetch!(options, :as)
    session = Gateway.get_shard(gateway, channel)

    params =
      options
      |> Keyword.put(:guild_id, guild_id)
      |> Keyword.put(:channel_id, channel_id)
      |> Map.new()

    update_voice_state = UpdateVoiceState.cast(params)

    Session.update_voice_state(session, update_voice_state)
  end

  def update_instance(user_id, guild_id, struct) do
    user_id
    |> get_instance(guild_id)
    |> Instance.get_manager()
    |> Manager.update(struct)
  end

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(state) do
    Supervisor.start_link(__MODULE__, state, name: Voice)
  end

  def init(_state) do
    Supervisor.init([], strategy: :one_for_one)
  end

  defp get_instance(user_id, guild_id) do
    spec = generate_instance_spec(user_id, guild_id)

    case start_child(Voice, spec) do
      {:ok, instance} ->
        instance
      {:error, {:already_started, instance}} ->
        instance
    end
  end

  defp generate_instance_spec(user_id, guild_id) do
    options = %Instance{user_id: user_id, guild_id: guild_id}
    spec = Instance.child_spec(options)
    %{spec | id: {user_id, guild_id}}
  end
end
