defmodule Coxir.Struct.Guild do
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

  def edit(%{id: id}, params),
    do: edit(id, params)

  def edit(guild, params) do
    API.request(:patch, "guilds/#{guild}", params)
    |> pretty
  end

  def delete(%{id: id}),
    do: delete(id)

  def delete(guild) do
    API.request(:delete, "guilds/#{guild}")
  end

  def leave(%{id: id}),
    do: leave(id)

  def leave(guild) do
    API.request(:delete, "users/@me/guilds/#{guild}")
  end

  def create_role(guild, params \\ %{})
  def create_role(%{id: id}, params),
    do: create_role(id, params)

  def create_role(guild, params) do
    API.request(:post, "guilds/#{guild}/roles", params)
    |> put(:guild_id, guild)
    |> Role.pretty
  end

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

  def create_channel(%{id: id}, params),
    do: create_channel(id, params)

  def create_channel(guild, params) do
    API.request(:post, "guilds/#{guild}/channels", params)
  end

  def add_member(%{id: id}, user, params),
    do: add_member(id, user, params)

  def add_member(guild, user, params) do
    API.request(:put, "guilds/#{guild}/members/#{user}", params)
    |> Member.pretty
  end

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

  def get_prune(%{id: id}, query),
    do: get_prune(id, query)

  def get_prune(guild, query) do
    API.request(:get, "guilds/#{guild}/prune", "", params: query)
  end

  def do_prune(%{id: id}, query),
    do: do_prune(id, query)

  def do_prune(guild, query) do
    API.request(:post, "guilds/#{guild}/prune", "", params: query)
  end

  def get_bans(%{id: id}),
    do: get_bans(id)

  def get_bans(guild) do
    API.request(:get, "guilds/#{guild}/bans")
  end

  def unban(%{id: id}, user),
    do: unban(id, user)

  def unban(guild, user) do
    API.request(:delete, "guilds/#{guild}/bans/#{user}")
  end

  def get_invites(%{id: id}),
    do: get_invites(id)

  def get_invites(guild) do
    API.request(:get, "guilds/#{guild}/invites")
  end

  def create_integration(%{id: id}, params),
    do: create_integration(id, params)

  def create_integration(guild, params) do
    API.request(:post, "guilds/#{guild}/integrations", params)
    |> put(:guild_id, guild)
  end

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

  def get_webhooks(%{id: id}),
    do: get_webhooks(id)

  def get_webhooks(guild) do
    API.request(:get, "guilds/#{guild}/webhooks")
  end

  def get_regions(%{id: id}),
    do: get_regions(id)

  def get_regions(guild) do
    API.request(:get, "guilds/#{guild}/regions")
  end

  def get_regions do
    API.request(:get, "voice/regions")
  end
end
