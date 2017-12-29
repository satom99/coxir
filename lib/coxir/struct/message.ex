defmodule Coxir.Struct.Message do
  use Coxir.Struct

  alias Coxir.Struct.{Guild, Channel}

  def pretty(struct) do
    struct
    |> replace(:guild_id, &Guild.get/1)
    |> replace(:channel_id, &Channel.get/1)
  end

  def reply(%{channel_id: channel}, content, tts \\ false),
    do: Channel.send_message(channel, content, tts)

  def edit(%{id: id, channel_id: channel}, content) do
    body = case content do
      [embed: embed] ->
        %{embed: embed}
      content ->
        %{content: content}
    end
    API.request(:patch, "channels/#{channel}/messages/#{id}", body)
    |> pretty
  end

  def delete(%{id: id, channel_id: channel}) do
    API.request(:delete, "channels/#{channel}/messages/#{id}")
  end

  def pin(%{id: id, channel_id: channel}) do
    API.request(:put, "channels/#{channel}/pins/#{id}")
  end

  def unpin(%{id: id, channel_id: channel}) do
    API.request(:delete, "channels/#{channel}/pins/#{id}")
  end

  def react(%{id: id, channel_id: channel}, emoji) do
    API.request(:put, "channels/#{channel}/messages/#{id}/reactions/#{emoji}/@me")
  end

  def get_reactions(%{id: id, channel_id: channel}, emoji) do
    API.request(:get, "channels/#{channel}/messages/#{id}/reactions/#{emoji}")
  end

  def delete_reaction(%{id: id, channel_id: channel}, emoji, user \\ "@me") do
    API.request(:delete, "channels/#{channel}/messages/#{id}/reactions/#{emoji}/#{user}")
  end

  def delete_all_reactions(%{id: id, channel_id: channel}) do
    API.request(:delete, "channels/#{channel}/messages/#{id}/reactions")
  end
end
