defmodule Coxir.Channel do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model

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

    embeds_many(:permission_overwrites, Overwrite)
    embeds_many(:recipients, User)

    belongs_to(:guild, Guild)
    belongs_to(:owner, User)
    belongs_to(:parent, Channel)
  end

  def fetch(id, options) do
    API.get("channels/#{id}", options)
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

  @spec send_message(t, Enum.t(), Loader.options()) :: Loader.result()
  def send_message(%Channel{id: id}, params, options \\ []) do
    params
    |> Map.new()
    |> Map.put(:channel_id, id)
    |> Message.create(options)
  end
end
