defmodule Coxir.Gateway.Dispatcher do
  @moduledoc """
  Work in progress.
  """
  use GenStage

  alias Coxir.Gateway.Payload
  alias Coxir.Gateway.Payload.Ready

  alias Coxir.Model.Loader
  alias Coxir.{Channel, Message}
  alias Coxir.{Guild, Role}
  alias Coxir.{Member, Presence, VoiceState}

  @type event ::
          {:READY, Ready.t()}
          | :RESUMED
          | {:CHANNEL_CREATE, Channel.t()}
          | {:CHANNEL_UPDATE, Channel.t()}
          | {:CHANNEL_DELETE, Channel.t()}
          | {:GUILD_CREATE, Guild.t()}
          | {:GUILD_UPDATE, Guild.t()}
          | {:GUILD_DELETE, Guild.t()}
          | {:GUILD_MEMBER_ADD, Member.t()}
          | {:GUILD_MEMBER_UPDATE, Member.t()}
          | {:GUILD_MEMBER_REMOVE, Member.t()}
          | {:GUILD_ROLE_CREATE, Role.t()}
          | {:GUILD_ROLE_UPDATE, Role.t()}
          | {:GUILD_ROLE_DELETE, Role.t()}
          | {:MESSAGE_CREATE, Message.t()}
          | {:MESSAGE_UPDATE, Message.t()}
          | {:MESSAGE_DELETE, Message.t()}
          | {:PRESENCE_UPDATE, Presence.t()}
          | {:VOICE_STATE_UPDATE, VoiceState.t()}
          | {:PAYLOAD, Payload.t()}

  def start_link(producer) do
    GenStage.start_link(__MODULE__, producer)
  end

  def init(producer) do
    {:producer_consumer, nil, subscribe_to: [producer]}
  end

  def handle_events(payloads, _from, state) do
    events = Enum.map(payloads, &handle_payload/1)
    {:noreply, events, state}
  end

  defp handle_payload(%Payload{event: "READY", data: object}) do
    ready = Ready.cast(object)
    {:READY, ready}
  end

  defp handle_payload(%Payload{event: "RESUMED"}) do
    :RESUMED
  end

  defp handle_payload(%Payload{event: "CHANNEL_CREATE", data: object}) do
    channel = Loader.load(Channel, object)
    {:CHANNEL_CREATE, channel}
  end

  defp handle_payload(%Payload{event: "CHANNEL_UPDATE", data: object}) do
    channel = Loader.load(Channel, object)
    {:CHANNEL_UPDATE, channel}
  end

  defp handle_payload(%Payload{event: "CHANNEL_DELETE", data: object}) do
    channel = Loader.load(Channel, object)
    Loader.unload(channel)
    {:CHANNEL_DELETE, channel}
  end

  defp handle_payload(%Payload{event: "GUILD_CREATE", data: object}) do
    guild = Loader.load(Guild, object)
    {:GUILD_CREATE, guild}
  end

  defp handle_payload(%Payload{event: "GUILD_UPDATE", data: object}) do
    guild = Loader.load(Guild, object)
    {:GUILD_UPDATE, guild}
  end

  defp handle_payload(%Payload{event: "GUILD_DELETE", data: object}) do
    guild = Loader.load(Guild, object)

    if not Map.has_key?(object, "unavailable") do
      Loader.unload(guild)
    end

    {:GUILD_DELETE, guild}
  end

  defp handle_payload(%Payload{event: "GUILD_MEMBER_ADD", data: object}) do
    member = Loader.load(Member, object)
    {:GUILD_MEMBER_ADD, member}
  end

  defp handle_payload(%Payload{event: "GUILD_MEMBER_UPDATE", data: object}) do
    member = Loader.load(Member, object)
    {:GUILD_MEMBER_UPDATE, member}
  end

  defp handle_payload(%Payload{event: "GUILD_MEMBER_REMOVE", data: object}) do
    member = Loader.load(Member, object)
    Loader.unload(member)
    {:GUILD_MEMBER_REMOVE, member}
  end

  defp handle_payload(%Payload{event: "GUILD_ROLE_CREATE", data: data}) do
    %{"guild_id" => guild_id, "role" => object} = data
    object = Map.put(object, "guild_id", guild_id)

    role = Loader.load(Role, object)
    {:GUILD_ROLE_CREATE, role}
  end

  defp handle_payload(%Payload{event: "GUILD_ROLE_UPDATE", data: data}) do
    %{"guild_id" => guild_id, "role" => object} = data
    object = Map.put(object, "guild_id", guild_id)

    role = Loader.load(Role, object)
    {:GUILD_ROLE_UPDATE, role}
  end

  defp handle_payload(%Payload{event: "GUILD_ROLE_DELETE", data: data}) do
    %{"guild_id" => guild_id, "role_id" => role_id} = data
    object = %{"id" => role_id, "guild_id" => guild_id}

    role = Loader.load(Role, object)
    Loader.unload(role)
    {:GUILD_ROLE_DELETE, role}
  end

  defp handle_payload(%Payload{event: "MESSAGE_CREATE", data: object}) do
    message = Loader.load(Message, object)
    {:MESSAGE_CREATE, message}
  end

  defp handle_payload(%Payload{event: "MESSAGE_UPDATE", data: object}) do
    message = Loader.load(Message, object)
    {:MESSAGE_UPDATE, message}
  end

  defp handle_payload(%Payload{event: "MESSAGE_DELETE", data: object}) do
    message = Loader.load(Message, object)
    Loader.unload(message)
    {:MESSAGE_DELETE, message}
  end

  defp handle_payload(%Payload{event: "PRESENCE_UPDATE", data: object}) do
    presence = Loader.load(Presence, object)
    {:PRESENCE_UPDATE, presence}
  end

  defp handle_payload(%Payload{event: "VOICE_STATE_UPDATE", data: object}) do
    voice_state = Loader.load(VoiceState, object)

    if is_nil(voice_state.channel_id) do
      Loader.unload(voice_state)
    end

    {:VOICE_STATE_UPDATE, voice_state}
  end

  defp handle_payload(%Payload{} = payload) do
    {:PAYLOAD, payload}
  end
end
