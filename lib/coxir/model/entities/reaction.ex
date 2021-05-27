defmodule Coxir.Reaction do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model, storable?: false

  @primary_key false

  @type t :: %Reaction{}

  embedded_schema do
    embeds_one(:member, Member)
    embeds_one(:emoji, Emoji)

    belongs_to(:message, Message)
    belongs_to(:channel, Channel)
    belongs_to(:guild, Guild)
    belongs_to(:user, User)
  end

  def insert(%{message_id: message_id, channel_id: channel_id, emoji: emoji}, options) do
    API.put("channels/#{channel_id}/messages/#{message_id}/reactions/#{emoji}/@me", options)
  end

  def delete(
        %Reaction{message_id: message_id, channel_id: channel_id, user_id: user_id, emoji: emoji},
        options
      ) do
    API.delete(
      "channels/#{channel_id}/messages/#{message_id}/reactions/#{emoji}/#{user_id}",
      options
    )
  end
end
