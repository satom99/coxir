defmodule Coxir.Gateway.Payload.HELLO do
  @moduledoc """
  Work in progress.
  """
  use Ecto.Schema

  embedded_schema do
    field(:heartbeat_interval, :integer)
  end
end
