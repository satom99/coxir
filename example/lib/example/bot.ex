defmodule Example.Bot do
  use Coxir.Gateway

  require Logger

  alias Coxir.{User, Guild, Channel, Message}

  def handle_event({:READY, _ready}) do
    Logger.info("Bot up and running.")
  end

  def handle_event(:RESUMED) do
    Logger.info("Bot back up and running.")
  end

  def handle_event({:MESSAGE_CREATE, message}) do
    message = Message.preload(message, [:author, channel: :guild])

    %Message{content: content, author: author, channel: channel} = message

    %User{username: username, discriminator: discriminator} = author

    %Channel{name: channel_name, guild: guild} = channel

    %Guild{name: guild_name} = guild

    Logger.info("[#{guild_name}] [##{channel_name}] #{username}##{discriminator}: #{content}")
  end

  def handle_event(_event) do
    :noop
  end
end
