defmodule Coxir.Voice.Payload.Ready do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Voice.Payload

  embedded_schema do
    field(:ssrc, :integer)
    field(:ip, :string)
    field(:port, :integer)
    field(:modes, {:array, :string})
  end
end
