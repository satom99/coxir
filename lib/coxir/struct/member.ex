defmodule Coxir.Struct.Member do
  use Coxir.Struct

  alias Coxir.Struct.{User, Role, Channel}

  def pretty(struct) do
    struct
    |> replace(:user_id, &User.get/1)
    |> replace(:voice_id, &Channel.get/1)
    |> replace(:roles, &Role.get/1)
  end

  def get(%{id: server}, %{id: member}),
    do: get(server, member)

  def get(server, member),
    do: get({server, member})

  def edit(%{id: id}, params),
    do: edit(id, params)

  def edit({guild, user}, params) do
    API.request(:patch, "guilds/#{guild}/members/#{user}", params)
  end

  def set_nick(%{id: id}, name), 
    do: set_nick(id, name)

  def set_nick({guild, user} = tuple, name) do
    params = %{nick: name}

    User.get()
    |> case do
      %{id: ^user} ->
        API.request(:patch, "guilds/#{guild}/members/@me/nick", params)
      _other ->
        edit(tuple, params)
    end
  end

  def kick(%{id: id}),
    do: kick(id)

  def kick({guild, user}) do
    API.request(:delete, "guilds/#{guild}/members/#{user}")
  end

  def ban(%{id: id}, query),
    do: ban(id, query)

  def ban({guild, user}, query) do
    API.request(:put, "guilds/#{guild}/bans/#{user}", "", params: query)
  end

  def add_role(%{id: id}, role),
    do: add_role(id, role)

  def add_role({guild, user}, role) do
    API.request(:put, "guilds/#{guild}/members/#{user}/roles/#{role}")
  end

  def remove_role(%{id: id}, role),
    do: remove_role(id, role)

  def remove_role({guild, user}, role) do
    API.request(:delete, "guilds/#{guild}/members/#{user}/roles/#{role}")
  end
end
