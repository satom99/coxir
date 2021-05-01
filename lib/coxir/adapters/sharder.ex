defmodule Coxir.Sharder do
  @moduledoc """
  Work in progress.
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
