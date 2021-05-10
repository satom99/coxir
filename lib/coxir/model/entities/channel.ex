defmodule Coxir.Channel do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model

  @type t :: %Channel{}

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

  @spec start_typing(t, Loader.options()) :: Loader.result()
  def start_typing(%Channel{id: id}, options \\ []) do
    API.post("channels/#{id}/typing", options)
  end

  @spec send_message(t, Enum.t(), Loader.options()) :: Loader.result()
  def send_message(%Channel{id: id}, params, options \\ []) do
    params
    |> Map.new()
    |> Map.put(:channel_id, id)
    |> Message.create(options)
  end

  @spec create_overwrite(t, Enum.t(), Loader.options()) :: Loader.result()
  def create_overwrite(%Channel{id: id}, params, options \\ []) do
    params
    |> Map.new()
    |> Map.put(:channel_id, id)
    |> Overwrite.create(options)
  end

  @spec create_webhook(t, Enum.t(), Loader.options()) :: Loader.result()
  def create_webhook(%Channel{id: id}, params, options \\ []) do
    params
    |> Map.new()
    |> Map.put(:channel_id, id)
    |> Webhook.create(options)
  end
end
