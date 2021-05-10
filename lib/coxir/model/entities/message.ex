defmodule Coxir.Message do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model

  alias Coxir.Message.Reference

  @type t :: %Message{}

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

    embeds_one(:message_reference, Reference)

    belongs_to(:channel, Channel, primary_key: true)
    belongs_to(:guild, Guild)
    belongs_to(:author, User)
    belongs_to(:referenced_message, Message)
  end

  def fetch({id, channel_id}, options) do
    API.get("channels/#{channel_id}/messages/#{id}", options)
  end

  def insert(%{channel_id: channel_id} = params, options) do
    API.post("channels/#{channel_id}/messages", params, options)
  end

  def patch({id, channel_id}, params, options) do
    API.patch("channels/#{channel_id}/messages/#{id}", params, options)
  end

  def drop({id, channel_id}, options) do
    API.delete("channels/#{channel_id}/messages/#{id}", options)
  end

  @spec reply(t, Enum.t(), Loader.options()) :: Loader.result()
  def reply(%Message{id: id, channel_id: channel_id}, params, options \\ []) do
    reference = %{message_id: id}

    params
    |> Map.new()
    |> Map.put(:channel_id, channel_id)
    |> Map.put(:message_reference, reference)
    |> create(options)
  end

  @spec pin(t, Loader.options()) :: Loader.result()
  def pin(%Message{id: id, channel_id: channel_id}, options \\ []) do
    API.put("channels/#{channel_id}/pins/#{id}", options)
  end

  @spec unpin(t, Loader.options()) :: Loader.result()
  def unpin(%Message{id: id, channel_id: channel_id}, options \\ []) do
    API.delete("channels/#{channel_id}/pins/#{id}", options)
  end
end
