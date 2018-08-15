defmodule Coxir.Struct.Message do
  @moduledoc """
  Defines methods used to interact with channel messages.

  Refer to [this](https://discordapp.com/developers/docs/resources/channel#message-object)
  for a list of fields and a broader documentation.

  In addition, the following fields are also embedded.
  - `guild` - a guild object
  - `channel` - a channel object
  """
  @type message :: String.t | map

  use Coxir.Struct

  alias Coxir.Struct.{Guild, Channel}

  def pretty(struct) do
    struct
    |> replace(:guild_id, &Guild.get/1)
    |> replace(:channel_id, &Channel.get/1)
  end

  @doc """
  Replies to a given message.

  Refer to `Coxir.Struct.Channel.send_message/2` for more information.
  """
  @spec reply(message, String.t | Enum.t) :: map

  def reply(%{channel_id: channel}, content),
    do: Channel.send_message(channel, content)

  @doc """
  Modifies a given message.

  Returns a message object upon success
  or a map containing error information.

  #### Content
  Either a string or an enumerable with
  the fields listed below.
  - `content` - the message contents (up to 2000 characters)
  - `embed` - embedded rich content, refer to
    [this](https://discordapp.com/developers/docs/resources/channel#embed-object)
  """
  @spec edit(message, String.t | Enum.t) :: map

  def edit(%{id: id, channel_id: channel}, content) do
    content = \
    cond do
      is_binary(content) ->
        %{content: content}
      true ->
        content
    end
    API.request(:patch, "channels/#{channel}/messages/#{id}", content)
    |> pretty
  end

  @doc """
  Deletes a given message.

  Returns the atom `:ok` upon success
  or a map containing error information.
  """
  @spec delete(message) :: :ok | map

  def delete(%{id: id, channel_id: channel}) do
    API.request(:delete, "channels/#{channel}/messages/#{id}")
  end

  @doc """
  Pins a given message.

  Returns the atom `:ok` upon success
  or a map containing error information.
  """
  @spec pin(message) :: :ok | map

  def pin(%{id: id, channel_id: channel}) do
    API.request(:put, "channels/#{channel}/pins/#{id}")
  end

  @doc """
  Unpins a given message.

  Returns the atom `:ok` upon success
  or a map containing error information.
  """
  @spec unpin(message) :: :ok | map

  def unpin(%{id: id, channel_id: channel}) do
    API.request(:delete, "channels/#{channel}/pins/#{id}")
  end

  @doc """
  Reacts to a given message.

  Returns the atom `:ok` upon success
  or a map containing error information.
  """
  @spec react(message, String.t) :: :ok | map

  def react(%{id: id, channel_id: channel}, emoji) do
    API.request(:put, "channels/#{channel}/messages/#{id}/reactions/#{emoji}/@me")
  end

  @doc """
  Fetches a list of users specific to a reaction on a given message.

  Returns a list of user objects upon success
  or a map containing error information.
  """
  @spec get_reactions(message, String.t) :: list | map

  def get_reactions(%{id: id, channel_id: channel}, emoji) do
    API.request(:get, "channels/#{channel}/messages/#{id}/reactions/#{emoji}")
  end

  @doc """
  Deletes a specific reaction from a given message.

  Returns the atom `:ok` upon success
  or a map containing error information.
  """
  @spec delete_reaction(message, String.t, String.t) :: :ok | map

  def delete_reaction(%{id: id, channel_id: channel}, emoji, user \\ "@me") do
    API.request(:delete, "channels/#{channel}/messages/#{id}/reactions/#{emoji}/#{user}")
  end

  @doc """
  Deletes all reactions from a given message.

  Returns the atom `:ok` upon success
  or a map containing error information.
  """
  @spec delete_all_reactions(message) :: :ok | map

  def delete_all_reactions(%{id: id, channel_id: channel}) do
    API.request(:delete, "channels/#{channel}/messages/#{id}/reactions")
  end
  
  @doc """
  Checks whether the given message is an activity.

  Returns a boolean.
  """
  @spec is_activity?(message) :: Boolean.t

  def is_activity?(message) do
    message
    |> get_activity
    != nil
  end

  @doc """
  Returns the activity of a given message.

  Returns a map if present
  and `nil` otherwise.
  """
  @spec get_activity(message) :: map | nil

  def get_activity(message) do
    message[:activity]
  end
end
