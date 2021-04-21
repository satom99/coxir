defmodule Coxir.Webhook do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model

  embedded_schema do
    field(:type, :integer)
    field(:name, :string)
    field(:avatar, :string)
    field(:token, :string)

    belongs_to(:channel, Channel, primary_key: true)
    belongs_to(:guild, Guild)
    belongs_to(:user, User)
    belongs_to(:source_guild, Guild)
    belongs_to(:source_channel, Channel)
  end
end
