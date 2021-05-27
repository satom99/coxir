defmodule Coxir.Gateway.Payload.MessageReactionRemoveAll do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Gateway.Payload

  embedded_schema do
    belongs_to(:channel, Channel)
    belongs_to(:message, Message)
    belongs_to(:guild, Guild)
  end
end
