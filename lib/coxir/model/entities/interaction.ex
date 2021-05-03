defmodule Coxir.Interaction do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model, storable?: false

  alias Coxir.Interaction.ApplicationCommandData

  embedded_schema do
    field(:application_id, Snowflake)
    field(:type, :integer)
    field(:token, :string)
    field(:version, :integer)

    embeds_one(:data, ApplicationCommandData)

    embeds_one(:user, User)
    embeds_one(:member, Member)

    belongs_to(:channel, Channel)
    belongs_to(:guild, Guild)
  end
end
