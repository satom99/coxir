defmodule Coxir.Struct.Overwrite do
  @moduledoc """
  Defines methods used to interact with channel permission overwrites.

  Refer to [this](https://discord.com/developers/docs/resources/channel#overwrite-object)
  for a list of fields and a broader documentation.
  """
  @type overwrite :: String.t | map

  use Coxir.Struct

  @doc false
  def get(id),
    do: super(id)

  @doc false
  def select(pattern)

  @doc """
  Modifies a given overwrite.

  Returns the atom `:ok` upon success
  or a map containing error information.

  #### Params
  Must be an enumerable with the fields listed below.
  - `allow` - the bitwise value of all allowed permissions
  - `deny` - the bitwise value of all denied permissions
  - `type` - `member` for a member or `role` for a role

  Refer to [this](https://discord.com/developers/docs/resources/channel#edit-channel-permissions)
  for a broader explanation on the fields and their defaults.
  """
  @spec edit(overwrite, Enum.t) :: :ok | map

  def edit(%{id: id, channel: channel}, params),
    do: edit(id, channel, params)

  @doc """
  Modifies a given overwrite.

  Refer to `edit/2` for more information.
  """
  @spec edit(String.t, String.t, Enum.t) :: :ok | map

  def edit(overwrite, channel, params) do
    API.request(:put, "channels/#{channel}/permissions/#{overwrite}", params)
  end

  @doc """
  Deletes a given overwrite.

  Returns the atom `:ok` upon success
  or a map containing error information.
  """
  @spec delete(overwrite) :: :ok | map

  def delete(%{id: id, channel: channel}),
    do: delete(id, channel)

  @doc """
  Deletes a given overwrite.

  Refer to `delete/1` for more information.
  """
  @spec delete(String.t, String.t) :: :ok | map

  def delete(overwrite, channel) do
    API.request(:delete, "channels/#{channel}/permissions/#{overwrite}")
  end
end
