defmodule Coxir.Gateway.Payload.GuildMembersChunk do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Gateway.Payload

  embedded_schema do
    field(:chunk_index, :integer)
    field(:chunk_count, :integer)
    field(:not_found, {:array, Snowflake})
    field(:nonce, :string)

    embeds_many(:members, Member)
    embeds_many(:presences, Presence)

    belongs_to(:guild, Guild)
  end
end
