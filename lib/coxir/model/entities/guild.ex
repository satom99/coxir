defmodule Coxir.Guild do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model

  @type t :: %Guild{}

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
    has_many(:bans, Ban)
    has_many(:members, Member)
    has_many(:voice_states, VoiceState)
  end

  def fetch(id, options) do
    API.get("guilds/#{id}", options)
  end

  def fetch_many(id, :roles, options) do
    with {:ok, objects} <- API.get("guilds/#{id}/roles", options) do
      objects = Enum.map(objects, &Map.put(&1, "guild_id", id))
      {:ok, objects}
    end
  end

  def fetch_many(id, :bans, options) do
    with {:ok, objects} <- API.get("guilds/#{id}/bans", options) do
      objects = Enum.map(objects, &Map.put(&1, "guild_id", id))
      {:ok, objects}
    end
  end

  def patch(id, params, options) do
    API.patch("guilds/#{id}", params, options)
  end

  def drop(id, options) do
    API.delete("guilds/#{id}", options)
  end

  @doc """
  Delegates to `Coxir.Member.get/2`.
  """
  @spec get_member(t, User.t() | Snowflake.t(), Loader.options()) :: Member.t() | Error.t()
  def get_member(guild, user, options \\ [])

  def get_member(guild, %User{id: user_id}, options) do
    get_member(guild, user_id, options)
  end

  def get_member(%Guild{id: id}, user_id, options) do
    Member.get({user_id, id}, options)
  end

  @spec get_prune_count(t, Loader.options()) :: non_neg_integer | Error.t()
  def get_prune_count(%Guild{id: id}, options \\ []) do
    query = Keyword.take(options, [:days, :include_roles])

    case API.get("guilds/#{id}/prune", query, options) do
      {:ok, %{"pruned" => pruned}} ->
        pruned

      {:error, error} ->
        error
    end
  end

  @spec prune(t, Enum.t(), Loader.options()) :: {:ok, non_neg_integer | nil} | Loader.result()
  def prune(%Guild{id: id}, params \\ %{}, options \\ []) do
    params = Map.new(params)
    result = API.post("guilds/#{id}/prune", params, options)

    with {:ok, %{"pruned" => pruned}} <- result do
      {:ok, pruned}
    end
  end

  @doc """
  Delegates to `Coxir.Ban.get/2`.
  """
  @spec get_ban(t, User.t() | Snowflake.t(), Loader.options()) :: Ban.t() | Error.t()
  def get_ban(guild, user, options \\ [])

  def get_ban(guild, %User{id: user_id}, options) do
    get_ban(guild, user_id, options)
  end

  def get_ban(%Guild{id: id}, user_id, options) do
    Ban.get({user_id, id}, options)
  end

  @spec create_channel(t, Enum.t(), Loader.options()) :: Loader.result()
  def create_channel(%Guild{id: id}, params, options \\ []) do
    params
    |> Map.new()
    |> Map.put(:guild_id, id)
    |> Channel.create(options)
  end

  @spec create_role(t, Enum.t(), Loader.options()) :: Loader.result()
  def create_role(%Guild{id: id}, params, options \\ []) do
    params
    |> Map.new()
    |> Map.put(:guild_id, id)
    |> Role.create(options)
  end
end
