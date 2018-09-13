defmodule Coxir.Stage.Middle do
  @moduledoc false

  use GenStage

  alias Coxir.Voice
  alias Coxir.Stage.Producer
  alias Coxir.Struct.{Guild, Role, Member, Channel, Message, User}

  def start_link do
    GenStage.start_link __MODULE__, :ok
  end

  def init(state) do
    {:producer_consumer, state, [subscribe_to: [Producer], buffer_size: 2000]}
  end

  def handle_events(events, _from, state) do
    events = events
    |> Enum.map(
      fn %{t: name, d: data} ->
        handle(name, data)
        |> case do
          :ignore -> :ignore
          data -> {name, data}
        end
      end
    )
    |> Enum.filter(& &1 != :ignore)

    {:noreply, events, state}
  end

  # Local
  def handle(:READY, data) do
    for guild <- data.guilds do
      handle(:GUILD_UPDATE, guild)
    end
    for channel <- data.private_channels do
      handle(:CHANNEL_CREATE, channel)
    end
    User.update(data.user)
    User.pretty(data.user)
  end
  def handle(:USER_UPDATE, data) do
    User.update(data)
    :ignore
  end

  # Channels
  def handle(:CHANNEL_CREATE, data) do
    Channel.update(data)
    :ignore
  end
  def handle(:CHANNEL_UPDATE, data) do
    handle(:CHANNEL_CREATE, data)
  end
  def handle(:CHANNEL_DELETE, data) do
    Channel.remove(data)
    :ignore
  end

  # Messages
  def handle(:MESSAGE_CREATE, data) do
    Message.update(data)
    Message.pretty(data)
  end
  def handle(:MESSAGE_UPDATE, data) do
    handle(:MESSAGE_CREATE, data)
  end
  def handle(:MESSAGE_DELETE, data) do
    Message.remove(data)
    Message.pretty(data)
  end
  def handle(:MESSAGE_DELETE_BULK, data) do
    for id <- data.ids do
      handle(:MESSAGE_DELETE, %{id: id, channel_id: data.channel_id})
    end
    :ignore
  end

  # Guilds
  def handle(:GUILD_CREATE, data) do
    for role <- data.roles do
      handle(:GUILD_ROLE_CREATE, %{role: role, guild_id: data.id})
    end
    for member <- data.members do
      handle(:GUILD_MEMBER_ADD, Map.put(member, :guild_id, data.id))
    end
    for channel <- data.channels do
      handle(:CHANNEL_CREATE, Map.put(channel, :guild_id, data.id))
    end
    for presence <- data.presences do
      handle(:PRESENCE_UPDATE, Map.put(presence, :guild_id, data.id))
    end
    for state <- data.voice_states do
      handle(:VOICE_STATE_UPDATE, Map.put(state, :guild_id, data.id))
    end
    data = data
    |> Map.update!(:roles, &(for role <- &1, do: role.id))
    |> Map.update!(:members, &(for member <- &1, do: {data.id, member.user.id}))
    |> Map.update!(:channels, &(for channel <- &1, do: channel.id))
    |> Map.delete(:presences)
    |> Map.delete(:voice_states)

    Guild.update(data)
    Guild.pretty(data)
  end
  def handle(:GUILD_UPDATE, data) do
    Guild.update(data)
    :ignore
  end
  def handle(:GUILD_DELETE, data) do
    Voice.stop(data.id)
    Guild.remove(data)
    :ignore
  end

  def handle(:GUILD_ROLE_CREATE, data) do
    data.role
    |> Map.put(:guild_id, data.guild_id)
    |> Role.update
    :ignore
  end
  def handle(:GUILD_ROLE_UPDATE, data) do
    handle(:GUILD_ROLE_CREATE, data)
  end
  def handle(:GUILD_ROLE_DELETE, data) do
    Role.remove(data.role_id)
    :ignore
  end

  def handle(:GUILD_MEMBER_ADD, data) do
    User.update(data.user)

    data = data
    |> Map.merge(
      %{
        id: {data.guild_id, data.user.id},
        user_id: data.user.id
      }
    )

    Member.update(data)
    Member.pretty(data)
  end
  def handle(:GUILD_MEMBER_UPDATE, data) do
    handle(:GUILD_MEMBER_ADD, data)
    :ignore
  end
  def handle(:GUILD_MEMBERS_CHUNK, data) do
    for member <- data.members do
      handle(:GUILD_MEMBER_ADD, Map.put(member, :guild_id, data.guild_id))
    end
    :ignore
  end
  def handle(:GUILD_MEMBER_REMOVE, data) do
    Member.remove({data.guild_id, data.user.id})
    Member.pretty(data)
  end
  def handle(:PRESENCE_UPDATE, data) do
    data
    |> Map.get(:guild_id)
    |> case do
      nil ->
        :ok
      _ok ->
        handle(:GUILD_MEMBER_UPDATE, data)
    end
    :ignore
  end

  def handle(:GUILD_EMOJIS_UPDATE, data) do
    Guild.update %{
      id: data.guild_id,
      emojis: data.emojis
    }
    :ignore
  end

  # Voice
  def handle(:VOICE_SERVER_UPDATE, data) do
    data
    |> Map.get(:guild_id)
    |> Voice.get
    |> case do
      nil -> :ok
      pid -> Voice.update(pid, data)
    end
    :ignore
  end

  def handle(:VOICE_STATE_UPDATE, data) do
    data
    |> Map.get(:guild_id)
    |> case do
      nil ->
        user = %{
          id: data.user_id,
          voice_id: data.channel_id
        }
        handle(:USER_UPDATE, user)
      _ok ->
        member = %{
          user: %{id: data.user_id},
          voice_id: data.channel_id,
          guild_id: data.guild_id
        }
        handle(:GUILD_MEMBER_UPDATE, member)
    end
    handle(:VOICE_SERVER_UPDATE, data)
    data
  end

  # Not handled on purpose,
  # Channels: pins, webhooks
  # Messages: reactions
  # Guilds: bans, integrations

  def handle(_event, data), do: data
end
