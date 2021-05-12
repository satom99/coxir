defmodule Coxir.Message.Attachment do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model, storable?: false

  @type t :: %Attachment{}

  embedded_schema do
    field(:filename, :string)
    field(:content_type, :string)
    field(:size, :integer)
    field(:url, :string)
    field(:proxy_url, :string)
    field(:height, :integer)
    field(:width, :integer)
  end
end
