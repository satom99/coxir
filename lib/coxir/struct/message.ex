defmodule Coxir.Struct.Message do
  use Coxir.Struct

  alias Coxir.Struct.{Guild, Channel}

  def pretty(struct) do
    struct
    |> replace(:guild_id, &Guild.get/1)
    |> replace(:channel_id, &Channel.get/1)
  end

  def reply(%{channel_id: channel}, content),
    do: Channel.send_message(channel, content)

  def edit(%{id: id, channel_id: channel}, content) do
    content = \
    cond do
      is_binary(content) ->
        %{content: content}
      true ->
        content
    end
    API.request(:patch, "channels/#{channel}/messages/#{id}", content)
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
