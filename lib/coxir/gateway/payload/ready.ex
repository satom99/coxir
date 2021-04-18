defmodule Coxir.Gateway.Payload.Ready do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Gateway.Payload

  embedded_schema do
    field(:v, :integer)
    field(:session_id, :string)
    field(:shard, {:array, :integer})
  end
end
