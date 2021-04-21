defmodule Coxir.Gateway.Payload.Ready do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Gateway.Payload

  # alias Coxir.{User, Guild}

  embedded_schema do
    field(:v, :integer)
    field(:session_id, :string)
    field(:shard, {:array, :integer})

    # embeds_one(:user, User)
    # embeds_many(:guilds, Guild)
  end
end
