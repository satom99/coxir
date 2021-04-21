defmodule Coxir.Gateway.Payload.Resume do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Gateway.Payload

  embedded_schema do
    field(:token, :string)
    field(:session_id, :string)
    field(:sequence, :integer)
  end
end
