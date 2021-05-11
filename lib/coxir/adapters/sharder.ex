defmodule Coxir.Sharder do
  @moduledoc """
  Handles how gateway shards are started.
  """
  alias Coxir.Gateway.Session

  @type sharder :: pid

  defstruct [
    :start_limit,
    :shard_count,
    :session_options
  ]

  @type t :: module

  @type options :: %__MODULE__{}

  @callback child_spec(options) :: Supervisor.child_spec()

  @callback get_shard(sharder, non_neg_integer) :: Session.session()
end
