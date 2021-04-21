defmodule Coxir.Guild do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model

  embedded_schema do
    field(:name, :string)
    field(:icon, :string)
    field(:splash, :string)
    field(:discovery_splash, :string)
    field(:permissions, :integer)
    field(:region, :string)
    field(:afk_timeout, :integer)
    field(:widget_enabled, :boolean)
    field(:verification_level, :integer)
    field(:default_message_notifications, :integer)
    field(:explicit_content_filter, :integer)
    field(:features, {:array, :string})
    field(:mfa_level, :integer)
    field(:application_id, Snowflake)
    field(:system_channel_flags, :integer)
    field(:joined_at, :utc_datetime)
    field(:large, :boolean)
    field(:unavailable, :boolean)
    field(:member_count, :integer)
    field(:max_presences, :integer)
    field(:max_members, :integer)
    field(:vanity_url_code, :string)
    field(:description, :string)
    field(:banner, :string)
    field(:premium_tier, :integer)
    field(:premium_subscription_count, :integer)
    field(:preferred_locale, :string)
    field(:max_video_channel_users, :integer)

    belongs_to(:owner, User)
    belongs_to(:afk_channel, Channel)
    belongs_to(:widget_channel, Channel)
    belongs_to(:system_channel, Channel)
    belongs_to(:rules_channel, Channel)
    belongs_to(:public_updates_channel, Channel)

    has_many(:roles, Role)
    has_many(:members, Member)
  end

  def fetch(id, options) do
    case API.get("guilds/#{id}", options) do
      {:ok, object} ->
        Loader.load(Guild, object)

      _other ->
        nil
    end
  end
end
