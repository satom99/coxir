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
    guild_id
    |> Guild.fetch_many(:roles, options)
    |> Enum.find(& &1.id == id)
  end
end
