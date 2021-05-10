defmodule Coxir.Interaction.ApplicationCommandDataOption do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model, storable?: false

  alias __MODULE__

  @primary_key false

  @type t :: %ApplicationCommandDataOption{}

  embedded_schema do
    field(:name, :string)
    field(:type, :integer)
    field(:value, :integer)

    embeds_many(:options, ApplicationCommandDataOption)
  end
end
