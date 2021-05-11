defmodule Coxir.Ban do
  @moduledoc """
  Represents a Discord guild ban.
  """
  use Coxir.Model, storable?: false

  @primary_key false

  @typedoc """
  The struct for a ban.
  """
  @type t :: %Ban{
          user: user,
          user_id: user_id,
          guild: guild,
          guild_id: guild_id
        }

  @typedoc """
  The coxir key of a channel.
  """
  @type key :: {user_id, guild_id}

  @typedoc """
  The id of the banned user.
  """
  @type user_id :: Snowflake.t()

  @typedoc """
  The banned user.

  Needs to be preloaded via `preload/3`.
  """
  @type user :: NotLoaded.t() | User.t() | Error.t()

  @typedoc """
  The id of the belonging guild.
  """
  @type guild_id :: Snowflake.t()

  @typedoc """
  The belonging guild.

  Needs to be preloaded via `preload/3`.
  """
  @type guild :: NotLoaded.t() | Guild.t() | Error.t()

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
