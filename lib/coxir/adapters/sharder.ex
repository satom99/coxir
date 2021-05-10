defmodule Coxir.Sharder do
  @moduledoc """
  Handles how gateway shards are started.
  """
  defstruct [
    :shard_count,
    :session_options
  ]

  @type t :: module

  @type options :: %__MODULE__{}

  @callback child_spec(options) :: Supervisor.child_spec()

  @callback get_shard(pid, integer) :: pid
end
