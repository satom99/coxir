defmodule Coxir.Message.Embed.Author do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model, storable?: false

  @primary_key false

  @type t :: %Author{}

  embedded_schema do
    field(:name, :string)
    field(:url, :string)
    field(:icon_url, :string)
    field(:proxy_icon_url, :string)
  end
end
