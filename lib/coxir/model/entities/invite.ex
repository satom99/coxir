defmodule Coxir.Invite do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model, storable?: false

  @primary_key false

  @type t :: %Invite{}

  embedded_schema do
    field(:code, :string, primary_key: true)
    field(:uses, :integer)
    field(:max_uses, :integer)
    field(:max_age, :integer)
    field(:temporary, :boolean)
    field(:target_type, :integer)
    field(:approximate_presence_count, :integer)
    field(:approximate_member_count, :integer)
    field(:created_at, :utc_datetime)
    field(:expires_at, :utc_datetime)

    belongs_to(:guild, Guild)
    belongs_to(:channel, Channel)
    belongs_to(:inviter, User)
    belongs_to(:target_user, User)
  end

  def fetch(code, options) do
    query = Keyword.take(options, [:with_counts, :with_expiration])
    API.get("invites/#{code}", query, options)
  end

  def insert(%{channel_id: channel_id} = params, options) do
    API.post("channels/#{channel_id}/invites", params, options)
  end

  def drop(code, options) do
    API.delete("invites/#{code}", options)
  end
end
