defmodule Coxir.Message.Embed.Video do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model, storable?: false

  @primary_key false

  @type t :: %Video{}

  embedded_schema do
    field(:url, :string)
    field(:proxy_url, :string)
    field(:height, :integer)
    field(:width, :integer)
  end
end
