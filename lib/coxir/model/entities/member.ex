defmodule Coxir.Member do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model

  @primary_key false

  embedded_schema do
    field(:nick, :string)
    field(:roles, {:array, Snowflake})
    field(:joined_at, :utc_datetime)
    field(:premium_since, :utc_datetime)
    field(:deaf, :boolean)
    field(:mute, :boolean)
    field(:pending, :boolean)
    field(:permissions, :integer)

    belongs_to(:user, User, primary_key: true)
    belongs_to(:guild, Guild, primary_key: true)
  end

  def fetch({user_id, guild_id}, options) do
    with {:ok, object} <- API.get("guilds/#{guild_id}/members/#{user_id}", options) do
      object = Map.put(object, "guild_id", guild_id)
      {:ok, object}
    end
  end

  def patch({user_id, guild_id}, params, options) do
    with {:ok, object} <- API.patch("guilds/#{guild_id}/members/#{user_id}", params, options) do
      object = Map.put(object, "guild_id", guild_id)
      {:ok, object}
    end
  end

  def drop({user_id, guild_id}, options) do
    API.delete("guilds/#{guild_id}/members/#{user_id}", options)
  end

  def preload(%Member{roles: [%Role{} | _rest] = roles} = member, :roles, options) do
    if options[:force] do
      roles = Enum.map(roles, & &1.id)
      member = %{member | roles: roles}
      preload(member, :roles, options)
    else
      member
    end
  end

  def preload(%Member{guild_id: guild_id, roles: roles} = member, :roles, options) do
    roles =
      roles
      |> Stream.map(&{&1, guild_id})
      |> Stream.map(&Role.get(&1, options))
      |> Stream.filter(& &1)
      |> Enum.to_list()

    %{member | roles: roles}
  end

  def preload(member, association, options) do
    super(member, association, options)
  end

  @doc false
  def create(params, options)

  @spec kick(t, Loader.options()) :: Loader.result()
  def kick(member, options \\ []) do
    delete(member, options)
  end
end
