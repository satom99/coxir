defmodule Coxir.Struct.Channel do
  @moduledoc """
  Defines methods used to interact with Discord channels.

  Refer to [this](https://discordapp.com/developers/docs/resources/channel#channel-object)
  for a list of fields and a broader documentation.

  In addition, the following fields are also embedded.
  - `owner` - an user object
  """
  @type channel :: String.t | map

  use Coxir.Struct

  alias Coxir.Struct.{User, Member, Overwrite, Message}

  def pretty(struct) do
    struct
    |> replace(:owner_id, &User.get/1)
  end

  @doc """
  Sends a message to a given channel.

  Returns a message object upon success
  or a map containing error information.

  #### Content
  Either a string or an enumerable with
  the fields listed below.
  - `content` - the message contents (up to 2000 characters)
  - `embed` - embedded rich content, refer to
    [this](https://discordapp.com/developers/docs/resources/channel#embed-object)
  - `nonce` - used for optimistic message sending
  - `file` - the path of the file being sent
  - `tts` - true if this is a TTS message

  Refer to [this](https://discordapp.com/developers/docs/resources/channel#create-message)
  for a broader explanation on the fields and their defaults.
  """
  @spec send_message(channel, String.t | Enum.t) :: map

  def send_message(%{id: id}, content),
    do: send_message(id, content)

  def send_message(channel, content) do
    content = \
    cond do
      is_binary(content) ->
        %{content: content}
      file = content[:file] ->
        %{file: file}
      true ->
        content
    end

    function = \
    cond do
      content[:file] ->
        :request_multipart
      true ->
        :request
    end

    arguments = [:post, "channels/#{channel}/messages", content]

    API
    |> apply(function, arguments)
    |> Message.pretty
  end

  @doc """
  Fetches a message from a given channel.

  Returns a message object upon success
  or a map containing error information.
  """
  @spec get_message(channel, String.t) :: map

  def get_message(%{id: id}, message),
    do: get_message(id, message)

  def get_message(channel, message) do
    Message.get(message)
    |> case do
      nil ->
        API.request(:get, "channels/#{channel}/messages/#{message}")
        |> Message.pretty
      message -> message
    end
  end

  @doc """
  Fetches messages from a given channel.

  Returns a list of message objects upon success
  or a map containing error information.

  #### Query
  Must be a keyword list with the fields listed below.
  - `around` - get messages around this message ID
  - `before` - get messages before this message ID
  - `after` - get messages after this message ID
  - `limit` - max number of messages to return

  Refer to [this](https://discordapp.com/developers/docs/resources/channel#get-channel-messages)
  for a broader explanation on the fields and their defaults.
  """
  @spec history(channel, Keyword.t) :: list | map

  def history(term, query \\ [])
  def history(%{id: id}, query),
    do: history(id, query)

  def history(channel, query) do
    API.request(:get, "channels/#{channel}/messages", "", params: query)
    |> case do
      list when is_list(list) ->
        for message <- list do
          Message.pretty(message)
        end
      error -> error
    end
  end

  @doc """
  Fetches the pinned messages from a given channel.

  Returns a list of message objects upon success
  or a map containing error information.
  """
  @spec get_pinned_messages(channel) :: list | map

  def get_pinned_messages(%{id: id}),
    do: get_pinned_messages(id)

  def get_pinned_messages(channel) do
    API.request(:get, "channels/#{channel}/pins")
    |> case do
      list when is_list(list) ->
        for message <- list do
          Message.pretty(message)
        end
      error -> error
    end
  end

  @doc """
  Deletes multiple messages from a given channel.

  Returns the atom `:ok` upon success
  or a map containing error information.
  """
  @spec bulk_delete_messages(channel, list) :: :ok | map

  def bulk_delete_messages(%{id: id}, messages),
    do: bulk_delete_messages(id, messages)

  def bulk_delete_messages(channel, messages) do
    API.request(:post, "channels/#{channel}/messages/bulk-delete", %{messages: messages})
  end

  @doc """
  Modifies a given channel.

  Returns a channel object upon success
  or a map containing error information.

  #### Params
  Must be an enumerable with the fields listed below.
  - `name` - channel name (2-100 characters)
  - `topic` - channel topic (up to 1024 characters)
  - `nsfw` - whether the channel is NSFW
  - `position` - the position in the left-hand listing
  - `bitrate` - the bitrate in bits of the voice channel
  - `user_limit` - the user limit of the voice channel
  - `permission_overwrites` - channel or category-specific permissions
  - `parent_id` - id of the new parent category

  Refer to [this](https://discordapp.com/developers/docs/resources/channel#modify-channel)
  for a broader explanation on the fields and their defaults.
  """
  @spec edit(channel, Enum.t) :: map

  def edit(%{id: id}, params),
    do: edit(id, params)

  def edit(channel, params) do
    API.request(:patch, "channels/#{channel}", params)
    |> pretty
  end

  @doc """
  Modifies the name of a given channel.

  Returns a channel object upon success
  or a map containing error information.
  """
  @spec set_name(channel, String.t) :: map

  def set_name(channel, name),
    do: edit(channel, name: name)

  @doc """
  Modifies the topic of a given channel.

  Returns a channel object upon success
  or a map containing error information.
  """
  @spec set_topic(channel, String.t) :: map

  def set_topic(channel, topic),
    do: edit(channel, topic: topic)

  @doc """
  Enables the NSFW status of a given channel.

  Returns a channel object upon success
  or a map containing error information.
  """
  @spec enable_nsfw(channel) :: map

  def enable_nsfw(channel) do
    edit(channel, nsfw: true)
  end

  @doc """
  Disables the NSFW status of a given channel.

  Returns a channel object upon success
  or a map containing error information.
  """
  @spec disable_nsfw(channel) :: map

  def disable_nsfw(channel) do
    edit(channel, nsfw: false)
  end

  @doc """
  Modifies the position of a given channel.

  Returns a channel object upon success
  or a map containing error information.
  """
  @spec set_position(channel, Integer.t) :: map

  def set_position(channel, position),
    do: edit(channel, position: position)

  @doc """
  Modifies the bitrate of a given voice channel.

  Returns a channel object upon success
  or a map containing error information.
  """
  @spec set_bitrate(channel, Integer.t) :: map

  def set_bitrate(channel, bitrate),
    do: edit(channel, bitrate: bitrate)

  @doc """
  Modifies the user limit of a given voice channel.

  Returns a channel object upon success
  or a map containing error information.
  """
  @spec set_user_limit(channel, Integer.t) :: map

  def set_user_limit(channel, limit),
    do: edit(channel, user_limit: limit)

  @doc """
  Modifies the permissions of a given channel.

  Returns a channel object upon success
  or a map containing error information.
  """
  @spec set_permissions(channel, Enum.t) :: map

  def set_permissions(channel, permissions),
    do: edit(channel, permission_overwrites: permissions)

  @doc """
  Modifies the parent id of a given channel.

  Returns a channel object upon success
  or a map containing error information.
  """
  @spec set_parent(channel, String.t) :: map

  def set_parent(channel, parent),
    do: edit(channel, parent_id: parent)

  @doc """
  Deletes a given channel.

  Returns a channel object upon success
  or a map containing error information.
  """
  @spec delete(channel) :: map

  def delete(%{id: id}),
    do: delete(id)

  def delete(channel) do
    API.request(:delete, "channels/#{channel}")
  end

  @doc """
  Triggers the typing indicator on a given channel.

  Returns the atom `:ok` upon success
  or a map containing error information.
  """
  @spec typing(channel) :: :ok | map

  def typing(%{id: id}),
    do: typing(id)

  def typing(channel) do
    API.request(:post, "channels/#{channel}/typing")
  end

  @doc """
  Creates a permission overwrite for a given channel.

  Refer to `Coxir.Struct.Overwrite.edit/2` for more information.
  """
  @spec create_permission(channel, String.t, Enum.t) :: map

  def create_permission(%{id: id}, overwrite, params),
    do: create_permission(id, overwrite, params)

  def create_permission(channel, overwrite, params),
    do: Overwrite.edit(overwrite, channel, params)

  @doc """
  Creates an invite for a given channel.

  Returns an invite object upon success
  or a map containing error information.

  #### Params
  Must be an enumerable with the fields listed below.
  - `max_uses` - max number of uses (0 if unlimited)
  - `max_age` - duration in seconds before expiry (0 if never)
  - `temporary` - whether this invite only grants temporary membership
  - `unique` - whether not to try to reuse a similar invite

  Refer to [this](https://discordapp.com/developers/docs/resources/channel#create-channel-invite)
  for a broader explanation on the fields and their defaults.
  """
  @spec create_invite(channel, Enum.t) :: map

  def create_invite(term, params \\ %{})
  def create_invite(%{id: id}, params),
    do: create_invite(id, params)

  def create_invite(channel, params) do
    API.request(:post, "channels/#{channel}/invites", params)
  end

  @doc """
  Fetches the invites from a given channel.

  Returns a list of invite objects upon success
  or a map containing error information.
  """
  @spec get_invites(channel) :: list | map

  def get_invites(%{id: id}),
    do: get_invites(id)

  def get_invites(channel) do
    API.request(:get, "channels/#{channel}/invites")
  end

  @doc """
  Creates a webhook for a given channel.

  Returns a webhook object upon success
  or a map containing error information.

  #### Params
  Must be an enumerable with the fields listed below.
  - `name` - name of the webhook (2-23 characters)
  - `avatar` - image for the default webhook avatar
  """
  @spec create_webhook(channel, Enum.t) :: map

  def create_webhook(%{id: id}, params),
    do: create_webhook(id, params)

  def create_webhook(channel, params) do
    API.request(:post, "channels/#{channel}/webhooks", params)
  end

  @doc """
  Fetches the webhooks from a given channel.

  Returns a list of webhook objects upon success
  or a map containing error information.
  """
  @spec get_webhooks(channel) :: list | map

  def get_webhooks(%{id: id}),
    do: get_webhooks(id)

  def get_webhooks(channel) do
    API.request(:get, "channels/#{channel}/webhooks")
  end

  @doc """
  Fetches the users currently in a given voice channel.

  Returns a list of user or member objects depending on
  whether it's a private or a guild channel respectively
  or a map containing error information.
  """
  @spec get_voice_members(channel) :: list | map

  def get_voice_members(%{id: id}),
    do: get_voice_members(id)

  def get_voice_members(channel) do
    pattern = %{voice_id: channel}
    User.select(pattern)
    |> case do
      [] -> Member.select(pattern)
      list -> list
    end
  end
end
