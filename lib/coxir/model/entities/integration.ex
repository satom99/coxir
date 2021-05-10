defmodule Coxir.Integration do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model

  @type t :: %Integration{}

  embedded_schema do
    field(:name, :string)
    field(:type, :string)
    field(:enabled, :boolean)
    field(:syncing, :boolean)
    field(:enable_emoticons, :boolean)
    field(:expire_behavior, :integer)
    field(:expire_grace_period, :integer)
    field(:synced_at, :utc_datetime)
    field(:subscriber_count, :integer)
    field(:revoked, :boolean)

    belongs_to(:guild, Guild, primary_key: true)
    belongs_to(:role, Role)
    belongs_to(:user, User)
  end
end
