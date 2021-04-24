defmodule Coxir.Gateway.Dispatcher do
  @moduledoc """
  Work in progress.
  """
  use GenStage

  alias Coxir.Gateway.Payload
  alias Coxir.Gateway.Payload.Ready

  alias Coxir.Model.Loader
  alias Coxir.{Channel, Message}
  alias Coxir.{Guild, Member}

  @type event ::
          {:READY, Ready.t()}
          | :RESUMED
          | {:CHANNEL_CREATE, Channel.t()}
          | {:CHANNEL_UPDATE, Channel.t()}
          | {:GUILD_CREATE, Guild.t()}
          | {:GUILD_UPDATE, Guild.t()}
          | {:GUILD_MEMBER_ADD, Member.t()}
          | {:GUILD_MEMBER_UPDATE, Member.t()}
          | {:MESSAGE_CREATE, Message.t()}
          | {:MESSAGE_UPDATE, Message.t()}

  def start_link(producer) do
    GenStage.start_link(__MODULE__, producer)
  end

  def init(producer) do
    {:producer_consumer, nil, subscribe_to: [producer]}
  end

  def handle_events(payloads, _from, state) do
    events =
      payloads
      |> Stream.map(&handle_payload/1)
      |> Stream.reject(&(&1 == :noop))
      |> Enum.to_list()

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

  defp handle_payload(%Payload{event: "GUILD_CREATE", data: object}) do
    guild = Loader.load(Guild, object)
    {:GUILD_CREATE, guild}
  end

  defp handle_payload(%Payload{event: "GUILD_UPDATE", data: object}) do
    guild = Loader.load(Guild, object)
    {:GUILD_UPDATE, guild}
  end

  defp handle_payload(%Payload{event: "GUILD_MEMBER_ADD", data: object}) do
    member = Loader.load(Member, object)
    {:GUILD_MEMBER_ADD, member}
  end

  defp handle_payload(%Payload{event: "GUILD_MEMBER_UPDATE", data: object}) do
    member = Loader.load(Member, object)
    {:GUILD_MEMBER_UPDATE, member}
  end

  defp handle_payload(%Payload{event: "MESSAGE_CREATE", data: object}) do
    message = Loader.load(Message, object)
    {:MESSAGE_CREATE, message}
  end

  defp handle_payload(%Payload{event: "MESSAGE_UPDATE", data: object}) do
    message = Loader.load(Message, object)
    {:MESSAGE_UPDATE, message}
  end

  defp handle_payload(%Payload{}) do
    :noop
  end
end
