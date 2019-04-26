defmodule Coxir.Struct.User do
  @moduledoc """
  Defines methods used to interact with Discord users.

  Refer to [this](https://discordapp.com/developers/docs/resources/user#user-object)
  for a list of fields and a broader documentation.

  In addition, the following fields are also embedded.
  - `voice` - a channel object
  - `avatar_url` - an URL for the avatar
  """
  @type user :: String.t | map

  use Coxir.Struct

  alias Coxir.Struct.{Channel}

  def pretty(struct) do
    struct
    |> replace(:voice_id, &Channel.get/1)
    |> put(:avatar_url, get_avatar(struct))
    |> put(:creation_date, get_creation_date(struct))
  end

  def get(user \\ :local)
  def get(%{id: id}),
    do: get(id)

  def get(:local) do
    get_id()
    |> get
  end

  def get(user) do
    super(user)
    |> case do
      nil ->
        API.request(:get, "users/#{user}")
        |> pretty
      user -> user
    end
  end

  @doc """
  Computes the local user's ID.

  Returns a snowflake.
  """
  @spec get_id() :: String.t

  def get_id do
    Coxir.token()
    |> String.split(".")
    |> Kernel.hd
    |> Base.decode64!
  end

  @doc """
  Modifies the local user.

  Returns an user object upon success
  or a map containing error information.

  #### Params
  Must be an enumerable with the fields listed below.
  - `username` - the user's username
  - `avatar` - the user's avatar

  Refer to [this](https://discordapp.com/developers/docs/resources/user#modify-current-user)
  for a broader explanation on the fields and their defaults.
  """
  @spec edit(Enum.t) :: map

  def edit(params) do
    API.request(:patch, "users/@me", params)
  end

  @doc """
  Changes the username of the local user.

  Returns an user object upon success
  or a map containing error information.
  """
  @spec set_username(String.t) :: map

  def set_username(name),
    do: edit(username: name)

  @doc """
  Changes the avatar of the local user.

  Returns an user object upon success
  or a map containing error information.

  #### Avatar
  Either a proper data URI scheme
  or the path of an image's file.

  Refer to [this](https://discordapp.com/developers/docs/resources/user#avatar-data)
  for a broader explanation.
  """
  @spec set_avatar(String.t) :: map

  def set_avatar(avatar) do
    cond do
      String.starts_with?(avatar, "data:image") ->
        edit(avatar: avatar)
      true ->
        avatar
        |> File.read
        |> case do
          {:ok, content} ->
            content = content
            |> Base.encode64

            scheme = "data:;base64,#{content}"

            edit(avatar: scheme)
          {:error, reason} ->
            reason = reason
            |> :file.format_error
            |> List.to_string

            %{error: reason}
        end
    end
  end

  @doc """
  Fetches a list of connections for the local user.

  Refer to [this](https://discordapp.com/developers/docs/resources/user#get-user-connections)
  for more information.
  """
  @spec get_connections() :: list | map

  def get_connections do
    API.request(:get, "users/@me/connections")
  end

  @doc """
  Fetches a list of guilds for the local user.

  Returns a list of partial guild objects
  or a map containing error information.

  #### Query
  Must be a keyword list with the fields listed below.
  - `before` -  get guilds before this guild ID
  - `after` - get guilds after this guild ID
  - `max` - max number of guilds to return

  Refer to [this](https://discordapp.com/developers/docs/resources/user#get-current-user-guilds)
  for a broader explanation on the fields and their defaults.
  """
  @spec get_guilds(Keyword.t) :: list | map

  def get_guilds(query \\ []) do
    API.request(:get, "users/@me/guilds", "", params: query)
  end

  @doc """
  Creates a DM channel with a given user.

  Returns a channel object upon success
  or a map containing error information.
  """
  @spec create_dm(user) :: map

  def create_dm(%{id: id}),
    do: create_dm(id)

  def create_dm(recipient) do
    API.request(:post, "users/@me/channels", %{recipient_id: recipient})
    |> Channel.pretty
  end

  @doc """
  Creates a group DM channel.

  Returns a channel object upon success
  or a map containing error information.

  #### Params
  Must be an enumerable with the fields listed below.
  - `access_tokens` - access tokens of users
  - `nicks` - a map of user ids and their respective nicknames

  Refer to [this](https://discordapp.com/developers/docs/resources/user#create-group-dm)
  for a broader explanation on the fields and their defaults.
  """
  @spec create_group(Enum.t) :: map

  def create_group(params) do
    API.request(:post, "users/@me/channels", params)
    |> Channel.pretty
  end

  @doc """
  Fetches a list of DM channels for the local user.

  Returns a list of channel objects upon success
  or a map containing error information.
  """
  @spec get_dms() :: list

  def get_dms do
    API.request(:get, "users/@me/channels")
    |> case do
      list when is_list(list) ->
        for channel <- list do
          Channel.pretty(channel)
        end
      error -> error
    end
  end

  @doc """
  Sends a direct message to a given user.

  Refer to `Coxir.Struct.Channel.send_message/2` for more information.
  """
  @spec send_message(user, String.t | Enum.t) :: map

  def send_message(%{id: id}, content),
    do: send_message(id, content)

  def send_message(user, content) do
    user
    |> create_dm
    |> case do
      %{id: channel} ->
        Channel.send_message(channel, content)
      other ->
        other
    end
  end

  @doc """
  Computes the URL for a given user's avatar.

  Returns a string upon success
  or a map containing error information.
  """
  @spec get_avatar(user) :: String.t | map

  def get_avatar(id) when is_binary(id) do
    get(id)
    |> case do
      %{id: _id} = user ->
        get_avatar(user)
      other ->
        other
    end
  end

  def get_avatar(%{avatar_url: value}), do: value
  def get_avatar(%{avatar: nil, discriminator: discriminator}) do
    index = discriminator
    |> String.to_integer
    |> rem(5)

    "https://cdn.discordapp.com/embed/avatars/#{index}.png"
  end
  def get_avatar(%{avatar: avatar, id: id}) do
    extension = avatar
    |> String.starts_with?("a_")
    |> case do
      true -> "gif"
      false -> "png"
    end

    "https://cdn.discordapp.com/avatars/#{id}/#{avatar}.#{extension}"
  end
  def get_avatar(_other), do: nil
  
  @doc """
  Computes the date a user made their account.

  Returns a map upon success
  or a map containing error information.
  """
  @spec get_creation_date(user) :: map

  def get_creation_date(id) when is_binary(id) do
    get(id)
    |> case do
      %{id: _id} = user ->
        get_creation_date(user)

      other ->
        other
    end
  end

  def get_creation_date(%{creation_date: value}), do: value

  def get_creation_date(%{id: id}) do
    id
    |> String.to_integer()
    |> :erlang.bsr(22)
    |> Kernel.+(1_420_070_400_000)
    |> DateTime.from_unix!(:millisecond)
  end

  def get_creation_date(_other), do: nil
end
