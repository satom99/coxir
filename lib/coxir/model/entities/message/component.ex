defmodule Coxir.Message.Component do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model, storable?: false

  @type t :: %Component{}

  embedded_schema do
    field(:type, :integer)
    field(:style, :integer)
    field(:label, :string)
    field(:custom_id, :string)
    field(:url, :string)
    field(:disabled, :boolean)

    embeds_one(:emoji, Emoji)

    embeds_many(:components, Component)
  end
end
