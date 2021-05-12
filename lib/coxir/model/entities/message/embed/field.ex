defmodule Coxir.Message.Embed.Field do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model, storable?: false

  @primary_key false

  @type t :: %Field{}

  embedded_schema do
    field(:name, :string)
    field(:value, :string)
    field(:inline, :boolean)
  end
end
