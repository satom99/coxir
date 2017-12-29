defmodule Coxir.Struct.Integration do
  use Coxir.Struct

  def edit(%{id: id, guild_id: guild}, params),
    do: edit(id, guild, params)

  def edit(integration, guild, params) do
    API.request(:patch, "guilds/#{guild}/integrations/#{integration}", params)
  end

  def sync(%{id: id, guild_id: guild}),
    do: sync(id, guild)

  def sync(integration, guild) do
    API.request(:post, "guilds/#{guild}/integrations/#{integration}/sync")
  end

  def delete(%{id: id, guild_id: guild}),
    do: delete(id, guild)

  def delete(integration, guild) do
    API.request(:delete, "guilds/#{guild}/integrations/#{integration}")
  end
end
