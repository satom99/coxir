defmodule Coxir.Interaction.ComponentsData do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model, storable?: false

  @primary_key false

  @type t :: %ComponentsData{}

  embedded_schema do
    field(:type, :integer)
    field(:label, :string)
    field(:style, :integer)
    field(:custom_id, :string)
  end
end
