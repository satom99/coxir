defmodule Coxir.Gateway.Sharder do
  @moduledoc """
  Work in progress.
  """
  defstruct [
    :shard_count,
    :session_options
  ]

  @type t :: module

  @callback child_spec(term) :: Supervisor.child_spec()
end
