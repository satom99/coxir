defmodule Coxir.Voice.Payload.Speaking do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Voice.Payload

  embedded_schema do
    field(:speaking, :integer)
    field(:delay, :integer)
    field(:ssrc, :integer)
  end
end
