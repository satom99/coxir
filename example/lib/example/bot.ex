defmodule Example.Bot do
  use Coxir.Gateway

  require Logger

  alias Coxir.Payload.Ready
  alias Coxir.{User, Guild, Channel, Message}

  def handle_event({:READY, ready}) do
    %Ready{shard: [shard, _shard_count], user: user} = ready

    %User{username: username, discriminator: discriminator} = user

    Logger.info("Shard ##{shard} ready for user #{username}##{discriminator}.")
  end

  def handle_event({:MESSAGE_CREATE, message}) do
    message = Message.preload(message, [:author, channel: :guild])

    %Message{content: content, author: author, channel: channel} = message

    %User{username: username, discriminator: discriminator} = author

    %Channel{name: channel_name, guild: guild} = channel

    line = "#{username}##{discriminator}: #{content}"

    with %Guild{name: guild_name} <- guild do
      Logger.info("[#{guild_name}] [##{channel_name}] #{line}")
    else
      nil -> Logger.info("[DM] #{line}")
    end
  end

  def handle_event(_event) do
    :noop
  end
end
