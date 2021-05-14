defmodule Coxir.Gateway.Dispatcher do
  @moduledoc """
  Work in progress.
  """
  use GenStage

  alias Coxir.Gateway.Payload
  alias Coxir.Gateway.Payload.{Ready, VoiceServerUpdate, VoiceInstanceUpdate}

  alias Coxir.Model.Loader
  alias Coxir.{Channel, Message, Interaction}
  alias Coxir.{User, Guild, Role}
  alias Coxir.{Member, Presence, VoiceState}
  alias Coxir.Voice

  @type event ::
          ready
          | resumed
          | channel_create
          | channel_update
          | channel_delete
          | thread_create
          | thread_update
          | thread_delete
          | guild_create
          | guild_update
          | guild_delete
          | guild_member_add
          | guild_member_update
          | guild_member_remove
          | guild_role_create
          | guild_role_update
          | guild_role_delete
          | interaction_create
          | message_create
          | message_update
          | message_delete
          | presence_update
          | user_update
          | voice_state_update
          | voice_server_update
          | voice_instance_update
          | payload

  @type ready :: {:READY, Ready.t()}

  @type resumed :: :RESUMED

  @type channel_create :: {:CHANNEL_CREATE, Channel.t()}

  @type channel_update :: {:CHANNEL_UPDATE, Channel.t()}

  @type channel_delete :: {:CHANNEL_DELETE, Channel.t()}

  @type thread_create :: {:THREAD_CREATE, Channel.t()}

  @type thread_update :: {:THREAD_UPDATE, Channel.t()}

  @type thread_delete :: {:THREAD_DELETE, Channel.t()}

  @type guild_create :: {:GUILD_CREATE, Guild.t()}

  @type guild_update :: {:GUILD_UPDATE, Guild.t()}

  @type guild_delete :: {:GUILD_DELETE, Guild.t()}

  @type guild_member_add :: {:GUILD_MEMBER_ADD, Member.t()}

  @type guild_member_update :: {:GUILD_MEMBER_UPDATE, Member.t()}

  @type guild_member_remove :: {:GUILD_MEMBER_REMOVE, Member.t()}

  @type guild_role_create :: {:GUILD_ROLE_CREATE, Role.t()}

  @type guild_role_update :: {:GUILD_ROLE_UPDATE, Role.t()}

  @type guild_role_delete :: {:GUILD_ROLE_DELETE, Role.t()}

  @type interaction_create :: {:INTERACTION_CREATE, Interaction.t()}

  @type message_create :: {:MESSAGE_CREATE, Message.t()}

  @type message_update :: {:MESSAGE_UPDATE, Message.t()}

  @type message_delete :: {:MESSAGE_DELETE, Message.t()}

  @type presence_update :: {:PRESENCE_UPDATE, Presence.t()}

  @type user_update :: {:USER_UPDATE, User.t()}

  @type voice_state_update :: {:VOICE_STATE_UPDATE, VoiceState.t()}

  @type voice_server_update :: {:VOICE_SERVER_UPDATE, VoiceServerUpdate.t()}

  @type voice_instance_update :: {:VOICE_INSTANCE_UPDATE, VoiceInstanceUpdate.t()}

  @type payload :: {:PAYLOAD, Payload.t()}

  def start_link(producer) do
    GenStage.start_link(__MODULE__, producer)
  end

  def init(producer) do
    {:producer_consumer, nil, subscribe_to: [producer]}
  end

  def handle_events(payloads, _from, state) do
    events = Enum.map(payloads, &handle_event/1)
    {:noreply, events, state}
  end

  defp handle_event(%Payload{event: "READY", data: object}) do
    ready = Ready.cast(object)
    {:READY, ready}
  end

  defp handle_event(%Payload{event: "RESUMED"}) do
    :RESUMED
  end

  defp handle_event(%Payload{event: "CHANNEL_CREATE", data: object}) do
    channel = Loader.load(Channel, object)
    {:CHANNEL_CREATE, channel}
  end

  defp handle_event(%Payload{event: "CHANNEL_UPDATE", data: object}) do
    channel = Loader.load(Channel, object)
    {:CHANNEL_UPDATE, channel}
  end

  defp handle_event(%Payload{event: "CHANNEL_DELETE", data: object}) do
    channel = Loader.load(Channel, object)
    Loader.unload(channel)
    {:CHANNEL_DELETE, channel}
  end

  defp handle_event(%Payload{event: "THREAD_CREATE", data: object}) do
    channel = Loader.load(Channel, object)
    {:THREAD_CREATE, channel}
  end

  defp handle_event(%Payload{event: "THREAD_UPDATE", data: object}) do
    channel = Loader.load(Channel, object)
    {:THREAD_UPDATE, channel}
  end

  defp handle_event(%Payload{event: "THREAD_DELETE", data: object}) do
    channel = Loader.load(Channel, object)
    Loader.unload(channel)
    {:THREAD_DELETE, channel}
  end

  defp handle_event(%Payload{event: "GUILD_CREATE", data: object} = payload) do
    %Guild{voice_states: voice_states} = guild = Loader.load(Guild, object)

    Enum.each(voice_states, &handle_voice(&1, payload))

    {:GUILD_CREATE, guild}
  end

  defp handle_event(%Payload{event: "GUILD_UPDATE", data: object}) do
    guild = Loader.load(Guild, object)
    {:GUILD_UPDATE, guild}
  end

  defp handle_event(%Payload{event: "GUILD_DELETE", data: object}) do
    guild = Loader.load(Guild, object)

    if not Map.has_key?(object, "unavailable") do
      Loader.unload(guild)
    end

    {:GUILD_DELETE, guild}
  end

  defp handle_event(%Payload{event: "GUILD_MEMBER_ADD", data: object}) do
    member = Loader.load(Member, object)
    {:GUILD_MEMBER_ADD, member}
  end

  defp handle_event(%Payload{event: "GUILD_MEMBER_UPDATE", data: object}) do
    member = Loader.load(Member, object)
    {:GUILD_MEMBER_UPDATE, member}
  end

  defp handle_event(%Payload{event: "GUILD_MEMBER_REMOVE", data: object}) do
    member = Loader.load(Member, object)
    Loader.unload(member)
    {:GUILD_MEMBER_REMOVE, member}
  end

  defp handle_event(%Payload{event: "GUILD_ROLE_CREATE", data: data}) do
    %{"guild_id" => guild_id, "role" => object} = data
    object = Map.put(object, "guild_id", guild_id)

    role = Loader.load(Role, object)
    {:GUILD_ROLE_CREATE, role}
  end

  defp handle_event(%Payload{event: "GUILD_ROLE_UPDATE", data: data}) do
    %{"guild_id" => guild_id, "role" => object} = data
    object = Map.put(object, "guild_id", guild_id)

    role = Loader.load(Role, object)
    {:GUILD_ROLE_UPDATE, role}
  end

  defp handle_event(%Payload{event: "GUILD_ROLE_DELETE", data: data}) do
    %{"guild_id" => guild_id, "role_id" => role_id} = data
    object = %{"id" => role_id, "guild_id" => guild_id}

    role = Loader.load(Role, object)
    Loader.unload(role)
    {:GUILD_ROLE_DELETE, role}
  end

  defp handle_event(%Payload{event: "INTERACTION_CREATE", data: object}) do
    interaction = Loader.load(Interaction, object)
    {:INTERACTION_CREATE, interaction}
  end

  defp handle_event(%Payload{event: "MESSAGE_CREATE", data: object}) do
    message = Loader.load(Message, object)
    {:MESSAGE_CREATE, message}
  end

  defp handle_event(%Payload{event: "MESSAGE_UPDATE", data: object}) do
    message = Loader.load(Message, object)
    {:MESSAGE_UPDATE, message}
  end

  defp handle_event(%Payload{event: "MESSAGE_DELETE", data: object}) do
    message = Loader.load(Message, object)
    Loader.unload(message)
    {:MESSAGE_DELETE, message}
  end

  defp handle_event(%Payload{event: "PRESENCE_UPDATE", data: object}) do
    presence = Loader.load(Presence, object)
    {:PRESENCE_UPDATE, presence}
  end

  defp handle_event(%Payload{event: "USER_UPDATE", data: object}) do
    user = Loader.load(User, object)
    {:USER_UPDATE, user}
  end

  defp handle_event(%Payload{event: "VOICE_STATE_UPDATE", data: object} = payload) do
    voice_state = Loader.load(VoiceState, object)

    if is_nil(voice_state.channel_id) do
      Loader.unload(voice_state)
    end

    handle_voice(voice_state, payload)

    {:VOICE_STATE_UPDATE, voice_state}
  end

  defp handle_event(%Payload{event: "VOICE_SERVER_UPDATE", data: object} = payload) do
    voice_server_update = VoiceServerUpdate.cast(object)

    handle_voice(voice_server_update, payload)

    {:VOICE_SERVER_UPDATE, voice_server_update}
  end

  defp handle_event(%Payload{} = payload) do
    {:PAYLOAD, payload}
  end

  defp handle_voice(
         %VoiceState{user_id: user_id, guild_id: guild_id} = voice_state,
         %Payload{user_id: user_id}
       ) do
    Voice.update(user_id, guild_id, voice_state)
  end

  defp handle_voice(
         %VoiceServerUpdate{guild_id: guild_id} = voice_server_update,
         %Payload{user_id: user_id}
       ) do
    Voice.update(user_id, guild_id, voice_server_update)
  end

  defp handle_voice(_struct, _payload) do
    :noop
  end
end
