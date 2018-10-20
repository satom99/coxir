defmodule Coxir.Struct.Member do
  @moduledoc """
  Defines methods used to interact with guild members.

  Refer to [this](https://discordapp.com/developers/docs/resources/guild#guild-member-object)
  for a list of fields and a broader documentation.

  In addition, the following fields are also embedded.
  - `user` - a user object
  - `voice` - a voice channel object
  - `roles` - a list of role objects
  """
  @type user :: map
  @type guild :: map
  @type member :: map

  use Coxir.Struct

  alias Coxir.Struct.{User, Role, Channel}

  def pretty(struct) do
    struct
    |> replace(:user_id, &User.get/1)
    |> replace(:voice_id, &Channel.get/1)
    |> replace(:roles, &Role.get/1)
  end

  @doc """
  Fetches a cached member object.

  Returns an object if found and `nil` otherwise.
  """
  @spec get(guild, user) :: map | nil

  def get(%{id: server}, %{id: member}),
    do: get(server, member)

  def get(server, member),
    do: get({server, member})

  @doc false
  def get(id),
    do: super(id)

  @doc """
  Modifies a given member.

  Returns the atom `:ok` upon success
  or a map containing error information.

  #### Params
  Must be an enumerable with the fields listed below.
  - `nick` - value to set the member's nickname to
  - `roles` - list of role ids the member is assigned
  - `mute` - whether the member is muted
  - `deaf` - whether the member is deafened
  - `channel_id` - id of a voice channel to move the member to

  Refer to [this](https://discordapp.com/developers/docs/resources/guild#modify-guild-member)
  for a broader explanation on the fields and their defaults.
  """
  @spec edit(member, Enum.t) :: :ok | map

  def edit(%{id: id}, params),
    do: edit(id, params)

  def edit({guild, user}, params) do
    API.request(:patch, "guilds/#{guild}/members/#{user}", params)
  end

  @doc """
  Changes the nickname of a given member.

  Returns a map with a `nick` field
  or a map containing error information.
  """
  @spec set_nick(member, String.t) :: map

  def set_nick(%{id: id}, name),
    do: set_nick(id, name)

  def set_nick({guild, user} = tuple, name) do
    params = %{nick: name}

    User.get_id()
    |> case do
      ^user ->
        API.request(:patch, "guilds/#{guild}/members/@me/nick", params)
      _other ->
        edit(tuple, params)
    end
  end

  @doc """
  Changes the voice channel of a given member.

  Returns the atom `:ok` upon success
  or a map containing error information.
  """
  @spec move(member, String.t) :: :ok | map

  def move(member, channel),
    do: edit(member, channel_id: channel)

  @doc """
  Kicks a given member.

  Returns the atom `:ok` upon success
  or a map containing error information.
  """
  @spec kick(member, String.t) :: :ok | map

  def kick(term, reason \\ "")
  def kick(%{id: id}, reason),
    do: kick(id, reason)

  def kick({guild, user}, reason) do
    API.request(:delete, "guilds/#{guild}/members/#{user}", "", params: [reason: reason])
  end

  @doc """
  Bans a given member.

  Returns the atom `:ok` upon success
  or a map containing error information.

  #### Query
  Must be a keyword list with the fields listed below.
  - `delete-message-days` - number of days to delete the messages for (0-7)
  - `reason` - reason for the ban
  """
  @spec ban(member, Keyword.t) :: :ok | map

  def ban(%{id: id}, query),
    do: ban(id, query)

  def ban({guild, user}, query) do
    API.request(:put, "guilds/#{guild}/bans/#{user}", "", params: query)
  end

  @doc """
  Adds a role to a given member.

  Returns the atom `:ok` upon success
  or a map containing error information.
  """
  @spec add_role(member, String.t) :: :ok | map

  def add_role(%{id: id}, role),
    do: add_role(id, role)

  def add_role({guild, user}, role) do
    API.request(:put, "guilds/#{guild}/members/#{user}/roles/#{role}")
  end

  @doc """
  Removes a role from a given member.

  Returns the atom `:ok` upon success
  or a map containing error information.
  """
  @spec remove_role(member, String.t) :: :ok | map

  def remove_role(%{id: id}, role),
    do: remove_role(id, role)

  def remove_role({guild, user}, role) do
    API.request(:delete, "guilds/#{guild}/members/#{user}/roles/#{role}")
  end

  @doc """
  Checks whether a given member has a role.

  Returns a boolean.
  """
  @spec has_role?(member, String.t) :: boolean

  def has_role?(%{roles: roles}, role) do
    roles
    |> Enum.find(& &1[:id] == role)
    != nil
  end
end
