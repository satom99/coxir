defmodule Coxir.Message.Component do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model, storable?: false

  @type t :: %Component{}

  embedded_schema do
    field(:type, :integer)
    field(:label, :string)
    field(:style, :integer)
    field(:custom_id, :string)
    embeds_many(:components, Component)
  end
end
