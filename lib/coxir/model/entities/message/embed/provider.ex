defmodule Coxir.Message.Embed.Provider do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model, storable?: false

  @primary_key false

  @type t :: %Provider{}

  embedded_schema do
    field(:name, :string)
    field(:url, :string)
  end
end
