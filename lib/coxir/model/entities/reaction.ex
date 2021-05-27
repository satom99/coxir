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

    belongs_to(:user, User)
    belongs_to(:channel, Channel)
    belongs_to(:guild, Guild)
    belongs_to(:message, Message)
  end
end
