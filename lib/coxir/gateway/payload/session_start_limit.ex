defmodule Coxir.Gateway.Payload.SessionStartLimit do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Gateway.Payload

  embedded_schema do
    field(:total, :integer)
    field(:remaining, :integer)
    field(:reset_after, :integer)
    field(:max_concurrency, :integer)
  end
end
