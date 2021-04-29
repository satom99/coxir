defmodule Coxir.Role do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model

  embedded_schema do
    field(:name, :string)
    field(:color, :integer)
    field(:hoist, :boolean)
    field(:position, :integer)
    field(:permissions, :integer)
    field(:managed, :boolean)
    field(:mentionable, :boolean)

    belongs_to(:guild, Guild, primary_key: true)
  end

  def fetch({id, guild_id}, options) do
    role =
      %Guild{id: guild_id}
      |> Guild.preload(:roles, options)
      |> Map.get(:roles)
      |> Enum.find(&(&1.id == id))

    if not is_nil(role) do
      {:ok, role}
    else
      {:error, 404, nil}
    end
  end

  def insert(%{guild_id: guild_id} = params, options) do
    with {:ok, object} <- API.post("guilds/#{guild_id}/roles", params, options) do
      object = Map.put(object, "guild_id", guild_id)
      {:ok, object}
    end
  end

  def patch({id, guild_id}, params, options) do
    API.patch("guilds/#{guild_id}/roles/#{id}", params, options)
  end

  def drop({id, guild_id}, options) do
    API.delete("guilds/#{guild_id}/roles/#{id}", options)
  end
end
