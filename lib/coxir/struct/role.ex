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
