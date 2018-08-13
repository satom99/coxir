defmodule Coxir.Struct.User do
  @moduledoc """
  Defines methods used to interact with Discord users.

  Refer to [this](https://discordapp.com/developers/docs/resources/user#user-object)
  for a list of fields and a broader documentation.

  In addition, the following fields are also embedded.
  - `voice` - a channel object
  """
  @type user :: String.t() | map

  use Coxir.Struct

  alias Coxir.Struct.{Channel}

  def pretty(struct) do
    struct
    |> replace(:voice_id, &Channel.get/1)
  end

  def get(user \\ "@me")
  def get(%{id: id}),
    do: get(id)

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
  @spec edit(Enum.t()) :: map

  def edit(params) do
    API.request(:patch, "users/@me", params)
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
  @spec get_guilds(Keyword.t()) :: list | map

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
  @spec create_group(Enum.t()) :: map

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
end
