defmodule Coxir.Message.Embed.Footer do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model, storable?: false

  @primary_key false

  @type t :: %Footer{}

  embedded_schema do
    field(:text, :string)
    field(:icon_url, :string)
    field(:proxy_icon_url, :string)
  end
end
