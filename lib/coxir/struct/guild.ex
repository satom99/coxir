defmodule Coxir.Struct.Guild do
  @moduledoc """
  Defines methods used to interact with Discord guilds.

  Refer to [this](https://discordapp.com/developers/docs/resources/guild#guild-object)
  for a list of fields and a broader documentation.

  In addition, the following fields are also embedded.
  - `owner` - a user object
  - `afk_channel` - a channel object
  - `embed_channel` - a channel object
  - `system_channel` - a channel object
  - `channels` - list of channel objects
  - `members` - list of member objects
  - `roles` - list of role objects
  """
  @type guild :: String.t | map

  use Coxir.Struct
  use Bitwise

  alias Coxir.Gateway
  alias Coxir.Struct.{User, Role, Member, Channel}

  def pretty(struct) do
    struct
    |> replace(:owner_id, &User.get/1)
    |> replace(:afk_channel_id, &Channel.get/1)
    |> replace(:embed_channel_id, &Channel.get/1)
    |> replace(:widget_channel_id, &Channel.get/1)
    |> replace(:system_channel_id, &Channel.get/1)
    |> replace(:channels, &Channel.get/1)
    |> replace(:members, &Member.get/1)
    |> replace(:roles, &Role.get/1)
  end

  @doc """
  Used to grab the shard of a given guild.

  Returns the `PID` of the shard's process.
  """
  @spec shard(guild) :: pid

  def shard(%{id: id}),
    do: shard(id)

  def shard(guild) do
    guild = guild
    |> String.to_integer

    shards = Gateway
    |> Supervisor.count_children
    |> Map.get(:workers)

    (guild >>> 22)
    |> rem(shards)
    |> Gateway.get
  end

  @doc """
  Modifies a given guild.

  Returns a guild object upon success
  or a map containing error information.

  #### Params
  Must be an enumerable with the fields listed below.
  - `name` - guild name
  - `region` - guild voice region
  - `icon` - base64 encoded 128x128 jpeg image
  - `splash` - base64 encoded 128x128 jpeg image
  - `afk_timeout` - voice AFK timeout in seconds
  - `afk_channel_id` - voice AFK channel
  - `system_channel_id` - channel to which system messages are sent

  Refer to [this](https://discordapp.com/developers/docs/resources/guild#modify-guild)
  for a broader explanation on the fields and their defaults.
  """
  @spec edit(guild, Enum.t) :: map

  def edit(%{id: id}, params),
    do: edit(id, params)

  def edit(guild, params) do
    API.request(:patch, "guilds/#{guild}", params)
    |> pretty
  end

  @doc """
  Changes the name of a given guild.

  Returns a guild object upon success
  or a map containing error information.
  """
  @spec set_name(guild, String.t) :: map

  def set_name(guild, name),
    do: edit(guild, name: name)

  @doc """
  Changes the icon of a given guild.

  Returns a guild object upon success
  or a map containing error information.
  """
  @spec set_icon(guild, String.t) :: map

  def set_icon(guild, icon),
    do: edit(guild, icon: icon)

  @doc """
  Changes the region of a given guild.

  Returns a guild object upon success
  or a map containing error information.
  """
  @spec set_region(guild, String.t) :: map

  def set_region(guild, region),
    do: edit(guild, region: region)

  @doc """
  Changes the splash of a given guild.

  Returns a guild object upon success
  or a map containing error information.
  """
  @spec set_splash(guild, String.t) :: map

  def set_splash(guild, splash),
    do: edit(guild, splash: splash)

  @doc """
  Changes the voice AFK timeout of a given guild.

  Returns a guild object upon success
  or a map containing error information.
  """
  @spec set_afk_timeout(guild, Integer.t) :: map

  def set_afk_timeout(guild, timeout),
    do: edit(guild, afk_timeout: timeout)

  @doc """
  Changes the voice AFK channel of a given guild.

  Returns a guild object upon success
  or a map containing error information.
  """
  @spec set_afk_channel(guild, String.t) :: map

  def set_afk_channel(guild, channel),
    do: edit(guild, afk_channel_id: channel)

  @doc """
  Changes the channel to which system messages are sent on a given guild.

  Returns a guild object upon success
  or a map containing error information.
  """
  @spec set_system_channel(guild, String.t) :: map

  def set_system_channel(guild, channel),
    do: edit(guild, system_channel_id: channel)

  @doc """
  Deletes a given guild.

  Returns the atom `:ok` upon success
  or a map containing error information.
  """
  @spec delete(guild) :: :ok | map

  def delete(%{id: id}),
    do: delete(id)

  def delete(guild) do
    API.request(:delete, "guilds/#{guild}")
  end

  @doc """
  Leaves from a given guild.

  Returns the atom `:ok` upon success
  or a map containing error information.
  """
  @spec leave(guild) :: :ok | map

  def leave(%{id: id}),
    do: leave(id)

  def leave(guild) do
    API.request(:delete, "users/@me/guilds/#{guild}")
  end

  @doc """
  Creates a role on a given guild.

  Returns a role object upon success
  or a map containing error information.

  #### Params
  Must be an enumerable with the fields listed below.
  - `name` - name of the role
  - `color` - RGB color value
  - `permissions` - bitwise of the permissions
  - `hoist` - whether the role should be displayed separately
  - `mentionable` - whether the role should be mentionable

  Refer to [this](https://discordapp.com/developers/docs/resources/guild#create-guild-role)
  for a broader explanation on the fields and their defaults.
  """
  @spec create_role(guild, Enum.t) :: map

  def create_role(guild, params \\ %{})
  def create_role(%{id: id}, params),
    do: create_role(id, params)

  def create_role(guild, params) do
    API.request(:post, "guilds/#{guild}/roles", params)
    |> put(:guild_id, guild)
    |> Role.pretty
  end

  @doc """
  Modifies the positions of a set of roles on a given guild.

  Returns a list of role objects upon success
  or a map containing error information.

  #### Params
  Must be a list of maps with the fields listed below.
  - `id` - snowflake of the role
  - `position` - sorting position of the role
  """
  @spec edit_role_positions(guild, list) :: list | map

  def edit_role_positions(%{id: id}, params),
    do: edit_role_positions(id, params)

  def edit_role_positions(guild, params) do
    API.request(:patch, "guilds/#{guild}/roles", params)
    |> case do
      list when is_list(list) ->
        for role <- list do
          role
          |> put(:guild_id, guild)
          |> Role.pretty
        end
      error -> error
    end
  end

  @doc """
  Fetches the roles from a given guild.

  Returns a list of role objects upon success
  or a map containing error information.
  """
  @spec get_roles(guild) :: list | map

  def get_roles(%{id: id}),
    do: get_roles(id)

  def get_roles(guild) do
    API.request(:get, "guilds/#{guild}/roles")
    |> case do
      list when is_list(list) ->
        for role <- list do
          role
          |> put(:guild_id, guild)
          |> Role.pretty
        end
      error -> error
    end
  end

  @doc """
  Creates a channel on a given guild.

  Returns a channel object upon success
  or a map containing error information.

  #### Params
  Must be an enumerable with the fields listed below.
  - `name` - channel name (2-100 characters)
  - `type` - the type of channel
  - `nswf` - whether the channel is NSFW
  - `bitrate` - the bitrate in bits of the voice channel
  - `user_limit` - the user limit of the voice channel
  - `permission_overwrites` - channel-specific permissions
  - `parent_id` - id of the parent category

  Refer to [this](https://discordapp.com/developers/docs/resources/guild#create-guild-channel)
  for a broader explanation on the fields and their defaults.
  """
  @spec create_channel(guild, Enum.t) :: map

  def create_channel(%{id: id}, params),
    do: create_channel(id, params)

  def create_channel(guild, params) do
    API.request(:post, "guilds/#{guild}/channels", params)
  end

  @doc """
  Adds a user to a given guild.

  Returns a member object upon success
  or a map containing error information.

  #### Params
  Must be an enumerable with the fields listed below.
  - `access_token` - an oauth2 access token
  - `nick` - value to set the user's nickname to
  - `roles` - list of role ids the user is assigned
  - `mute` - whether the user is muted
  - `deaf` - whether the user is deafened

  Refer to [this](https://discordapp.com/developers/docs/resources/guild#add-guild-member)
  for a broader explanation on the fields and their defaults.
  """
  @spec add_member(guild, String.t, Enum.t) :: map

  def add_member(%{id: id}, user, params),
    do: add_member(id, user, params)

  def add_member(guild, user, params) do
    API.request(:put, "guilds/#{guild}/members/#{user}", params)
    |> Member.pretty
  end

  @doc """
  Fetches a member from a given guild.

  Returns a member object upon success
  or a map containing error information.
  """
  @spec get_member(guild, String.t) :: map

  def get_member(%{id: id}, user),
    do: get_member(id, user)

  def get_member(guild, user) do
    Member.get({guild, user})
    |> case do
      nil ->
        API.request(:get, "guilds/#{guild}/members/#{user}")
        |> put(:id, {guild, user})
        |> Member.pretty
      member -> member
    end
  end

  @doc """
  Fetches the members from a given guild.

  Returns a list of member objects upon success
  or a map containing error information.

  #### Query
  Must be a keyword list with the fields listed below.
  - `limit` - max number of members to return (1-1000)
  - `after` - the highest user id in the previous page

  Refer to [this](https://discordapp.com/developers/docs/resources/guild#list-guild-members)
  for a broader explanation on the fields and their defaults.
  """
  @spec list_members(guild, Keyword.t) :: list | map

  def list_members(term, query \\ [])
  def list_members(%{id: id}, query),
    do: list_members(id, query)

  def list_members(guild, query) do
    API.request(:get, "guilds/#{guild}/members", "", params: query)
    |> case do
      list when is_list(list) ->
        for member <- list do
          member
          |> put(:id, {guild, member.user.id})
          |> Member.pretty
        end
      error -> error
    end
  end

  @doc """
  Gets the number of members that would be removed in a prune.

  Returns a map with a `pruned` field
  or a map containing error information.

  #### Query
  Must be a keyword list with the fields listed below.
  - `days` - number of days to count prune for (1 or more)
  """
  @spec get_prune(guild, Keyword.t) :: map

  def get_prune(%{id: id}, query),
    do: get_prune(id, query)

  def get_prune(guild, query) do
    API.request(:get, "guilds/#{guild}/prune", "", params: query)
  end

  @doc """
  Begins a prune operation for a given guild.

  Returns a map with a `pruned` field
  or a map containing error information.

  #### Query
  Must be a keyword list with the fields listed below.
  - `days` - number of days to count prune for (1 or more)
  """
  @spec do_prune(guild, Keyword.t) :: map

  def do_prune(%{id: id}, query),
    do: do_prune(id, query)

  def do_prune(guild, query) do
    API.request(:post, "guilds/#{guild}/prune", "", params: query)
  end

  @doc """
  Fetches the bans from a given guild.

  Returns a list of ban objects
  or a map containing error information.
  """
  @spec get_bans(guild) :: list | map

  def get_bans(%{id: id}),
    do: get_bans(id)

  def get_bans(guild) do
    API.request(:get, "guilds/#{guild}/bans")
  end
  
  @doc """
  Fetches the ban for a user on a given guild.

  Returns a ban object or a map
  containing error information.
  """
  @spec get_ban(guild, String.t) :: map

  def get_ban(%{id: id}, user),
    do: get_ban(id, user)

  def get_ban(guild, user) do
    API.request(:get, "guilds/#{guild}/bans/#{user}")
  end

  @doc """
  Removes the ban for a user on a given guild.

  Returns the atom `:ok` upon success
  or a map containing error information.
  """
  @spec unban(guild, String.t) :: :ok | map

  def unban(%{id: id}, user),
    do: unban(id, user)

  def unban(guild, user) do
    API.request(:delete, "guilds/#{guild}/bans/#{user}")
  end

  @doc """
  Fetches the invites from a given guild.

  Returns a list of invite objects upon success
  or a map containing error information.
  """
  @spec get_invites(guild) :: list | map

  def get_invites(%{id: id}),
    do: get_invites(id)

  def get_invites(guild) do
    API.request(:get, "guilds/#{guild}/invites")
  end

  @doc """
  Attaches an integration to a given guild.

  Returns the atom `:ok` upon success
  or a map containing error information.

  #### Params
  Must be an enumerable with the fields listed below.
  - `type` - the integration type
  - `id` - the integration id
  """
  @spec create_integration(guild, Enum.t) :: :ok | map

  def create_integration(%{id: id}, params),
    do: create_integration(id, params)

  def create_integration(guild, params) do
    API.request(:post, "guilds/#{guild}/integrations", params)
    |> put(:guild_id, guild)
  end

  @doc """
  Fetches the integrations from a given guild.

  Returns a list of integration objects
  or a map containing error information.
  """
  @spec get_integrations(guild) :: list | map

  def get_integrations(%{id: id}),
    do: get_integrations(id)

  def get_integrations(guild) do
    API.request(:get, "guilds/#{guild}/integrations")
    |> case do
      list when is_list(list) ->
        for integration <- list do
          integration
          |> put(:guild_id, guild)
        end
      error -> error
    end
  end

  @doc """
  Fetches the webhooks from a given guild.

  Returns a list of webhook objects
  or a map containing error information.
  """
  @spec get_webhooks(guild) :: list | map

  def get_webhooks(%{id: id}),
    do: get_webhooks(id)

  def get_webhooks(guild) do
    API.request(:get, "guilds/#{guild}/webhooks")
  end

  @doc """
  Fetches the voice regions for a given guild.

  Returns a list of voice region objects
  or a map containing error information.
  """
  @spec get_regions(guild) :: list | map

  def get_regions(%{id: id}),
    do: get_regions(id)

  def get_regions(guild) do
    API.request(:get, "guilds/#{guild}/regions")
  end

  @doc """
  Fetches a list of voice regions.

  Returns a list of voice region objects
  or a map containing error information.
  """
  @spec get_regions :: list | map

  def get_regions do
    API.request(:get, "voice/regions")
  end
  
  @doc """
  Fetches the vanity url code of a given guild.

  Returns a string representing the code
  or a map containing error information.
  """
  @spec get_vanity_code(guild) :: String.t | map

  def get_vanity_code(%{id: id}),
    do: get_vanity_code(id)

  def get_vanity_code(guild) do
    API.request(:get, "guilds/#{guild}/vanity-url")
    |> case do
      %{error: _value} = error ->
        error
      invite ->
        invite[:code]
    end
  end
end
