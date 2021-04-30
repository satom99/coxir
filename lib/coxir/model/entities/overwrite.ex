defmodule Coxir.Overwrite do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model

  embedded_schema do
    field(:type, :integer)
    field(:allow, :integer)
    field(:deny, :integer)

    belongs_to(:channel, Channel, primary_key: true)
  end
end
