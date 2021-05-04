defmodule Coxir.Voice.Payload.Hello do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Voice.Payload

  embedded_schema do
    field(:heartbeat_interval, :integer)
  end
end
