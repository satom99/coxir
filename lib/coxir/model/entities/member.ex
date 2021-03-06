defmodule Coxir.Member do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model

  @primary_key false

  @type t :: %Member{}

  embedded_schema do
    field(:nick, :string)
    field(:roles, {:array, Snowflake})
    field(:joined_at, :utc_datetime)
    field(:premium_since, :utc_datetime)
    field(:deaf, :boolean)
    field(:mute, :boolean)
    field(:pending, :boolean)
    field(:permissions, :integer)

    field(:voice_state, :any, virtual: true)

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
      |> Enum.to_list()

    %{member | roles: roles}
  end

  def preload(%Member{voice_state: %VoiceState{}} = member, :voice_state, options) do
    if options[:force] do
      member = %{member | voice_state: nil}
      preload(member, :voice_state, options)
    else
      member
    end
  end

  def preload(%Member{user_id: user_id, guild_id: guild_id} = member, :voice_state, options) do
    voice_state = VoiceState.get({user_id, guild_id}, options)
    %{member | voice_state: voice_state}
  end

  def preload(member, association, options) do
    super(member, association, options)
  end

  @spec add_role(t, Role.t() | Snowflake.t(), Loader.options()) :: Loader.result()
  def add_role(member, role, options \\ [])

  def add_role(member, %Role{id: role_id}, options) do
    add_role(member, role_id, options)
  end

  def add_role(%Member{user_id: user_id, guild_id: guild_id}, role_id, options) do
    API.put("guilds/#{guild_id}/members/#{user_id}/roles/#{role_id}", options)
  end

  @spec remove_role(t, Role.t() | Snowflake.t(), Loader.options()) :: Loader.result()
  def remove_role(member, role, options \\ [])

  def remove_role(member, %Role{id: id}, options) do
    remove_role(member, id, options)
  end

  def remove_role(%Member{user_id: user_id, guild_id: guild_id}, role_id, options) do
    API.delete("guilds/#{guild_id}/members/#{user_id}/roles/#{role_id}", options)
  end

  @spec has_role?(t, Role.t() | Snowflake.t(), Loader.options()) :: boolean
  def has_role?(member, role, options \\ [])

  def has_role?(member, %Role{id: role_id}, options) do
    has_role?(member, role_id, options)
  end

  def has_role?(member, role_id, options) do
    member = preload!(member, :roles, options)
    %Member{roles: roles} = member

    roles
    |> Stream.map(& &1.id)
    |> Enum.find_value(false, &(&1 == role_id))
  end

  @spec kick(t, Loader.options()) :: Loader.result()
  def kick(member, options \\ []) do
    delete(member, options)
  end

  @spec ban(t, Enum.t(), Loader.options()) :: Loader.result()
  def ban(%Member{user_id: user_id, guild_id: guild_id}, params, options \\ []) do
    params
    |> Map.new()
    |> Map.put(:user_id, user_id)
    |> Map.put(:guild_id, guild_id)
    |> Ban.create(options)
  end
end
