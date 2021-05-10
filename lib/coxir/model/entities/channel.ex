defmodule Coxir.Channel do
  @moduledoc """
  Represents a Discord channel.
  """
  use Coxir.Model

  @type t :: %Channel{
          id: id,
          type: type,
          position: position,
          name: name,
          topic: topic,
          nsfw: nsfw,
          bitrate: bitrate,
          user_limit: user_limit,
          rate_limit_per_user: rate_limit_per_user,
          icon: icon,
          application_id: application_id,
          last_pin_timestamp: last_pin_timestamp,
          rtc_region: rtc_region,
          video_quality_mode: video_quality_mode,
          recipients: recipients,
          permission_overwrites: permission_overwrites,
          webhooks: webhooks,
          voice_states: voice_states,
          guild: guild,
          guild_id: guild_id,
          owner: owner,
          owner_id: owner_id,
          parent: parent,
          parent_id: parent_id
        }

  @type id :: Snowflake.t()

  @type type :: non_neg_integer

  @type position :: non_neg_integer | nil

  @type name :: String.t() | nil

  @type topic :: String.t() | nil

  @type nsfw :: boolean | nil

  @type bitrate :: non_neg_integer | nil

  @type user_limit :: non_neg_integer | nil

  @type rate_limit_per_user :: non_neg_integer | nil

  @type icon :: String.t() | nil

  @type application_id :: Snowflake.t() | nil

  @type last_pin_timestamp :: DateTime.t() | nil

  @type rtc_region :: String.t() | nil

  @type video_quality_mode :: non_neg_integer | nil

  @type recipients :: list(User.t()) | nil

  @type permission_overwrites :: NotLoaded.t() | Error.t() | list(Overwrite.t())

  @type webhooks :: NotLoaded.t() | Error.t() | list(Webhook.t())

  @type voice_states :: NotLoaded.t() | list(VoiceState.t())

  @type guild_id :: Snowflake.t() | nil

  @type guild :: NotLoaded.t() | Guild.t() | nil

  @type owner_id :: Snowflake.t() | nil

  @type owner :: NotLoaded.t() | User.t() | nil

  @type parent_id :: Snowflake.t() | nil

  @type parent :: NotLoaded.t() | t | nil

  embedded_schema do
    field(:type, :integer)
    field(:position, :integer)
    field(:name, :string)
    field(:topic, :string)
    field(:nsfw, :boolean)
    field(:bitrate, :integer)
    field(:user_limit, :integer)
    field(:rate_limit_per_user, :integer)
    field(:icon, :string)
    field(:application_id, Snowflake)
    field(:last_pin_timestamp, :utc_datetime)
    field(:rtc_region, :string)
    field(:video_quality_mode, :integer)

    embeds_many(:recipients, User)

    has_many(:permission_overwrites, Overwrite)
    has_many(:webhooks, Webhook)
    has_many(:voice_states, VoiceState)

    belongs_to(:guild, Guild)
    belongs_to(:owner, User)
    belongs_to(:parent, Channel)
  end

  def fetch(id, options) do
    API.get("channels/#{id}", options)
  end

  def fetch_many(id, :permission_overwrites, options) do
    %Channel{permission_overwrites: overwrites} = get(id, options)
    {:ok, overwrites}
  end

  def fetch_many(id, :webhooks, options) do
    API.get("channels/#{id}/webhooks", options)
  end

  def insert(%{guild_id: guild_id} = params, options) do
    API.post("guilds/#{guild_id}/channels", params, options)
  end

  def insert(%{recipient_id: _recipient_id} = params, options) do
    API.post("users/@me/channels", params, options)
  end

  def patch(id, params, options) do
    API.patch("channels/#{id}", params, options)
  end

  def drop(id, options) do
    API.delete("channels/#{id}", options)
  end

  def preload(%Channel{recipients: recipients} = channel, :recipients, options) do
    recipients =
      recipients
      |> Stream.map(& &1.id)
      |> Stream.map(&User.get(&1, options))
      |> Stream.filter(& &1)
      |> Enum.to_list()

    %{channel | recipients: recipients}
  end

  def preload(channel, association, options) do
    super(channel, association, options)
  end

  @doc """
  Triggers the typing indicator on a given channel.
  """
  @spec start_typing(t, Loader.options()) :: Loader.result()
  def start_typing(%Channel{id: id}, options \\ []) do
    API.post("channels/#{id}/typing", options)
  end

  @doc """
  Delegates to `Coxir.Message.create/2`.
  """
  @spec send_message(t, Enum.t(), Loader.options()) :: Loader.result()
  def send_message(%Channel{id: id}, params, options \\ []) do
    params
    |> Map.new()
    |> Map.put(:channel_id, id)
    |> Message.create(options)
  end

  @doc """
  Delegates to `Coxir.Overwrite.create/2`.
  """
  @spec create_overwrite(t, Enum.t(), Loader.options()) :: Loader.result()
  def create_overwrite(%Channel{id: id}, params, options \\ []) do
    params
    |> Map.new()
    |> Map.put(:channel_id, id)
    |> Overwrite.create(options)
  end

  @doc """
  Delegates to `Coxir.Webhook.create/2`.
  """
  @spec create_webhook(t, Enum.t(), Loader.options()) :: Loader.result()
  def create_webhook(%Channel{id: id}, params, options \\ []) do
    params
    |> Map.new()
    |> Map.put(:channel_id, id)
    |> Webhook.create(options)
  end
end
