defmodule Coxir.Gateway.Payload.GatewayInfo do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Gateway.Payload

  alias Coxir.Gateway.Payload.SessionStartLimit

  embedded_schema do
    field(:url, :string)
    field(:shards, :integer)

    embeds_one(:session_start_limit, SessionStartLimit)
  end
end
