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
end
