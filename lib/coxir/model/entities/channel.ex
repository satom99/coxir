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

  @typedoc """
  The id of the channel.
  """
  @type id :: Snowflake.t()

  @typedoc """
  The type of the channel. For a list of types have a look [here](https://discord.com/developers/docs/resources/channel#channel-object-channel-types).
  """
  @type type :: non_neg_integer | nil

  @typedoc """
  Sorting position of the channel.
  """
  @type position :: non_neg_integer | nil

  @typedoc """
  The name of the channel.
  """
  @type name :: String.t() | nil

  @typedoc """
  The topic of the channel.
  """
  @type topic :: String.t() | nil

  @typedoc """
  Whether the channel is nsfw.
  """
  @type nsfw :: boolean | nil

  @typedoc """
  The bitrate (in bits) of the voice channel.
  """
  @type bitrate :: non_neg_integer | nil

  @typedoc """
  The user limit of the voice channel.
  """
  @type user_limit :: non_neg_integer | nil

  @typedoc """
  Amount of seconds a user has to wait before sending another message.
  """
  @type rate_limit_per_user :: non_neg_integer | nil

  @typedoc """
  The icon hash of the channel.
  """
  @type icon :: String.t() | nil

  @typedoc """
  Application id of the group DM creator if it is bot-created.
  """
  @type application_id :: Snowflake.t() | nil

  @typedoc """
  The voice region id for the voice channel, automatic when nil.
  """
  @type rtc_region :: String.t() | nil

  @typedoc """
  The camera video quality mode of the voice channel.
  """
  @type video_quality_mode :: non_neg_integer | nil

  @typedoc """
  The recipients of the DM.
  """
  @type recipients :: list(User.t()) | nil

  @typedoc """
  Permission overwrites for members and roles.
  """
  @type permission_overwrites :: NotLoaded.t() | list(Overwrite.t()) | Error.t()

  @typedoc """
  Webhooks configured for the channel.
  """
  @type webhooks :: NotLoaded.t() | list(Webhook.t()) | Error.t()

  @typedoc """
  Active voice states for the voice channel.
  """
  @type voice_states :: NotLoaded.t() | list(VoiceState.t())

  @typedoc """
  The id of the guild the channel belongs to.
  """
  @type guild_id :: Snowflake.t() | nil

  @typedoc """
  The guild the channel belongs to.
  """
  @type guild :: NotLoaded.t() | Guild.t() | nil | Error.t()

  @typedoc """
  The id of the creator of the group DM or thread.
  """
  @type owner_id :: Snowflake.t() | nil

  @typedoc """
  The creator of the group DM or thread.
  """
  @type owner :: NotLoaded.t() | User.t() | nil | Error.t()

  @typedoc """
  The id of the parent category for guild channels. The id of the belonging channel for threads.
  """
  @type parent_id :: Snowflake.t() | nil

  @typedoc """
  The parent category for guild channels. The belonging channel for threads.
  """
  @type parent :: NotLoaded.t() | t | nil | Error.t()

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
