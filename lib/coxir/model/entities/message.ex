defmodule Coxir.Message do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model

  embedded_schema do
    field(:content, :string)
    field(:timestamp, :utc_datetime)
    field(:edited_timestamp, :utc_datetime)
    field(:tts, :boolean)
    field(:mention_everyone, :boolean)
    field(:mention_roles, {:array, Snowflake})
    field(:nonce, :string)
    field(:pinned, :boolean)
    field(:type, :integer)
    field(:flags, :integer)

    belongs_to(:channel, Channel, primary_key: true)
    belongs_to(:guild, Guild)
    belongs_to(:author, User)
  end

  def fetch({id, channel_id}, options) do
    case API.get("channels/#{channel_id}/messages/#{id}", options) do
      {:ok, object} ->
        Loader.load(Message, object)

      _other ->
        nil
    end
  end
end
