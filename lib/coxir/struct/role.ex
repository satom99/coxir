defmodule Coxir.Struct.Role do
  use Coxir.Struct

  def edit(%{id: id, guild_id: guild}, params),
    do: edit(id, guild, params)

  def edit(role, guild, params) do
    API.request(:patch, "guilds/#{guild}/roles/#{role}", params)
    |> put(:guild_id, guild)
  end

  def delete(%{id: id, guild_id: guild}),
    do: delete(id, guild)

  def delete(role, guild) do
    API.request(:delete, "guilds/#{guild}/roles/#{role}")
  end
end
