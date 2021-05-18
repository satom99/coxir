defmodule Coxir.Gateway.Payload.RequestGuildMembers do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Gateway.Payload

  embedded_schema do
    field(:query, :string)
    field(:limit, :integer)
    field(:presences, :boolean)
    field(:user_ids, {:array, Snowflake})
    field(:nonce, :string)

    belongs_to(:guild, Guild)
  end
end
