defmodule Coxir.Gateway.Payload.Hello do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Gateway.Payload

  embedded_schema do
    field(:heartbeat_interval, :integer)
  end
end
