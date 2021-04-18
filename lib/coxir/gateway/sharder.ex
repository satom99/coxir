defmodule Coxir.Gateway.Sharder do
  @moduledoc """
  Work in progress.
  """
  @type t :: module

  @callback child_spec(term) :: Supervisor.child_spec()
end
