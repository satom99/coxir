defmodule Coxir.Gateway.Payload.MessageReactionRemoveEmoji do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Gateway.Payload

  embedded_schema do
    embeds_one(:emoji, Emoji)

    belongs_to(:channel, Channel)
    belongs_to(:message, Message)
    belongs_to(:guild, Guild)
  end
end
