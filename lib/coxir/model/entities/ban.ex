defmodule Coxir.Ban do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model, storable?: false

  @primary_key false

  embedded_schema do
    belongs_to(:user, User, primary_key: true)
    belongs_to(:guild, Guild, primary_key: true)
  end

  def fetch({user_id, guild_id}, options) do
    API.get("guilds/#{guild_id}/bans/#{user_id}", options)
  end

  def insert(%{user_id: user_id, guild_id: guild_id} = params, options) do
    API.put("guilds/#{guild_id}/bans/#{user_id}", params, options)
  end

  def drop({user_id, guild_id}, options) do
    API.delete("guilds/#{guild_id}/bans/#{user_id}", options)
  end
end
