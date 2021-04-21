defmodule Coxir.Gateway.Dispatcher do
  @moduledoc """
  Work in progress.
  """
  use GenStage

  alias Coxir.Gateway.Payload
  alias Coxir.Gateway.Payload.Ready

  alias Coxir.Model.Loader
  alias Coxir.{Guild, Channel, Message}

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

  defp handle_payload(%Payload{event: "GUILD_CREATE", data: object}) do
    guild = Loader.load(Guild, object)
    {:GUILD_CREATE, guild}
  end

  defp handle_payload(%Payload{event: "GUILD_UPDATE", data: object}) do
    guild = Loader.load(Guild, object)
    {:GUILD_UPDATE, guild}
  end

  defp handle_payload(%Payload{event: "CHANNEL_CREATE", data: object}) do
    channel = Loader.load(Channel, object)
    {:CHANNEL_CREATE, channel}
  end

  defp handle_payload(%Payload{event: "CHANNEL_UPDATE", data: object}) do
    channel = Loader.load(Channel, object)
    {:CHANNEL_UPDATE, channel}
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
