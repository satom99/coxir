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
    with {:ok, objects} <- Guild.fetch_many(guild_id, :roles, options) do
      if object = Enum.find(objects, &(&1["id"] == id)) do
        {:ok, object}
      else
        {:error, 404, nil}
      end
    end
  end
end
