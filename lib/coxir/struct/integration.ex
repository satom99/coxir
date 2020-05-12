defmodule Coxir.Struct.Integration do
  @moduledoc """
  Defines methods used to interact with guild integrations.

  Refer to [this](https://discord.com/developers/docs/resources/guild#integration-object)
  for a list of fields and a broader documentation.
  """
  @type integration :: String.t | map

  use Coxir.Struct

  @doc false
  def get(id),
    do: super(id)

  @doc false
  def select(pattern)

  @doc """
  Modifies a given integration.

  Returns the atom `:ok` upon success
  or a map containing error information.

  #### Params
  Must be an enumerable with the fields listed below.
  - `expire_behavior` - when an integration subscription lapses
  - `expire_grace_period` - period (in seconds) where lapsed subscriptions will be ignored
  - `enable_emoticons` - whether emoticons should be synced for this integration (*Twitch*)

  Refer to [this](https://discord.com/developers/docs/resources/guild#modify-guild-integration)
  for a broader explanation on the fields and their defaults.
  """
  @spec edit(integration, Enum.t) :: :ok | map

  def edit(%{id: id, guild_id: guild}, params),
    do: edit(id, guild, params)

  @doc """
  Modifies a given integration.

  Refer to `edit/2` for more information.
  """
  @spec edit(String.t, String.t, Enum.t) :: :ok | map

  def edit(integration, guild, params) do
    API.request(:patch, "guilds/#{guild}/integrations/#{integration}", params)
  end

  @doc """
  Synchronizes a given integration.

  Returns the atom `:ok` upon success
  or a map containing error information.
  """
  @spec sync(integration) :: :ok | map

  def sync(%{id: id, guild_id: guild}),
    do: sync(id, guild)

  @doc """
  Synchronizes a given integration.

  Refer to `sync/1` for more information.
  """
  @spec sync(String.t, String.t) :: :ok | map

  def sync(integration, guild) do
    API.request(:post, "guilds/#{guild}/integrations/#{integration}/sync")
  end

  @doc """
  Deletes a given integration.

  Returns the atom `:ok` upon success
  or a map containing error information.
  """
  @spec delete(integration) :: :ok | map

  def delete(%{id: id, guild_id: guild}),
    do: delete(id, guild)

  @doc """
  Deletes a given integration.

  Refer to `delete/1` for more information.
  """
  @spec delete(String.t, String.t) :: :ok | map

  def delete(integration, guild) do
    API.request(:delete, "guilds/#{guild}/integrations/#{integration}")
  end
end
