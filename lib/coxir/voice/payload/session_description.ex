defmodule Coxir.Voice.Payload.SessionDescription do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Voice.Payload

  embedded_schema do
    field(:mode, :string)
    field(:secret_key, {:array, :integer})
  end
end
