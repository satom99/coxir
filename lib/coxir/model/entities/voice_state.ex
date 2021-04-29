defmodule Coxir.VoiceState do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model

  @primary_key false

  embedded_schema do
    field(:session_id, Snowflake)
    field(:deaf, :boolean)
    field(:mute, :boolean)
    field(:self_deaf, :boolean)
    field(:self_mute, :boolean)
    field(:self_stream, :boolean)
    field(:self_video, :boolean)
    field(:suppress, :boolean)
    field(:request_to_speak_timestamp, :utc_datetime)

    field(:member, :any, virtual: true)

    belongs_to(:user, User, primary_key: true)
    belongs_to(:guild, Guild, primary_key: true)
    belongs_to(:channel, Channel)
  end

  def preload(%VoiceState{member: %Member{}} = voice_state, :member, options) do
    if options[:force] do
      voice_state = %{voice_state | member: nil}
      preload(voice_state, :member, options)
    else
      voice_state
    end
  end

  def preload(%VoiceState{user_id: user_id, guild_id: guild_id} = voice_state, :member, options) do
    member = Member.get({user_id, guild_id}, options)
    %{voice_state | member: member}
  end

  def preload(voice_state, association, options) do
    super(voice_state, association, options)
  end

  @doc false
  def create(params, options)
end
