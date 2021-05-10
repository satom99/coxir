defmodule Coxir.Interaction.ApplicationCommandData do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model, storable?: false

  alias Coxir.Interaction.ApplicationCommandDataOption

  @primary_key false

  @type t :: %ApplicationCommandData{}

  embedded_schema do
    field(:name, :string)

    embeds_many(:options, ApplicationCommandDataOption)
  end
end
