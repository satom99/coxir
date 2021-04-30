defmodule Coxir.Payload.Hello do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Payload

  embedded_schema do
    field(:heartbeat_interval, :integer)
  end
end
