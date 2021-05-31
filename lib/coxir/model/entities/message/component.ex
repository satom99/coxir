defmodule Coxir.Message.Component do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model, storable?: false
  alias Coxir.Interaction.ComponentsData

  @type t :: %Component{}

  embedded_schema do
    field(:type, :integer)
    embeds_many(:components, Component)
  end
end
