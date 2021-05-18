defmodule Coxir.Gateway.Payload.RequestGuildMembers do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Gateway.Payload

  embedded_schema do
    field(:guild_id, Snowflake)
    field(:query, :string)
    field(:limit, :integer)
    field(:presences, :boolean)
    field(:user_ids, {:array, Snowflake})
    field(:nonce, :string)
  end
end
