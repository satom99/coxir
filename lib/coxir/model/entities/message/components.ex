defmodule Coxir.Message.Components do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model, storable?: false
  alias Coxir.Interaction.ComponentsData

  @type t :: %Components{}

  embedded_schema do
    field(:type, :integer)
    belongs_to(:components, ComponentsData)
  end
end
