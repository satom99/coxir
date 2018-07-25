defmodule Coxir.Struct.Role do
  @moduledoc """
  Defines methods used to interact with guild roles.

  Refer to [this](https://discordapp.com/developers/docs/topics/permissions#role-object)
  for a list of fields and a broader documentation.
  """
  @type role :: String.t | map

  use Coxir.Struct

  @doc false
  def get(id),
    do: super(id)

  @doc false
  def select(pattern)

  @doc """
  Modifies a given role.

  Returns a role object upon success
  or a map containing error information.

  #### Params
  Must be an enumerable with the fields listed below.
  - `name` - name of the role
  - `color` - RGB color value
  - `permissions` - bitwise of the permissions
  - `hoist` - whether the role should be displayed separately
  - `mentionable` - whether the role should be mentionable

  Refer to [this](https://discordapp.com/developers/docs/resources/guild#modify-guild-role)
  for a broader explanation on the fields and their defaults.
  """
  @spec edit(role, Enum.t) :: map

  def edit(%{id: id, guild_id: guild}, params),
    do: edit(id, guild, params)

  @doc """
  Modifies a given role.

  Refer to `edit/2` for more information.
  """
  @spec edit(String.t, String.t, Enum.t) :: map

  def edit(role, guild, params) do
    API.request(:patch, "guilds/#{guild}/roles/#{role}", params)
    |> put(:guild_id, guild)
  end

  @doc """
  Modifies the name of a given role.

  Returns a role object upon success
  or a map containing error information.
  """
  @spec set_name(role, String.t, String.t) :: map

  def set_name(%{id: id, guild_id: guild}, name),
    do: set_name(id, guild, name)

  def set_name(role, guild, name),
    do: edit(role, guild, name: name)

  @doc """
  Modifies the color of a given role.

  Returns a role object upon success
  or a map containing error information.
  """
  @spec set_color(role, String.t, Integer.t) :: map

  def set_color(%{id: id, guild_id: guild}, color),
    do: set_color(id, guild, color)

  def set_color(role, guild, color),
    do: edit(role, guild, color: color)

  @doc """
  Modifies the permissions of a given role.

  Returns a role object upon success
  or a map containing error information.
  """
  @spec set_permissions(role, String.t, Integer.t) :: map

  def set_permissions(%{id: id, guild_id: guild}, permissions),
    do: set_permissions(id, guild, permissions)

  def set_permissions(role, guild, permissions),
    do: edit(role, guild, permissions: permissions)

  @doc """
  Modifies the hoisting of a given role.

  Returns a role object upon success
  or a map containing error information.
  """
  @spec set_hoist(role, Boolean.t) :: map

  def set_hoist(%{id: id, guild_id: guild}, bool),
    do: set_hoist(id, guild, bool)

  def set_hoist(role, guild, bool),
    do: edit(role, guild, hoist: bool)

  @doc """
  Modifies the mentioning status of a given role.

  Returns a role object upon success
  or a map containing error information.
  """
  @spec set_mentionable(role, Boolean.t) :: map

  def set_mentionable(%{id: id, guild_id: guild}, bool),
    do: set_mentionable(id, guild, bool)

  def set_mentionable(role, guild, bool),
    do: edit(role, guild, mentionable: bool)

  @doc """
  Deletes a given role.

  Returns the atom `:ok` upon success
  or a map containing error information.
  """
  @spec delete(role) :: :ok | map

  def delete(%{id: id, guild_id: guild}),
    do: delete(id, guild)

  @doc """
  Deletes a given role.

  Refer to `delete/1` for more information.
  """
  @spec delete(String.t, String.t) :: :ok | map

  def delete(role, guild) do
    API.request(:delete, "guilds/#{guild}/roles/#{role}")
  end
end
