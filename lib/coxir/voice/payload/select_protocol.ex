defmodule Coxir.Voice.Payload.SelectProtocol do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Voice.Payload

  embedded_schema do
    field(:address, :string)
    field(:port, :integer)
    field(:mode, :string)
  end
end
