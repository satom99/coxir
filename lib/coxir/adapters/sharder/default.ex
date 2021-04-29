defmodule Coxir.Sharder.Default do
  @moduledoc """
  Work in progress.
  """
  use Supervisor

  alias Coxir.Sharder
  alias Coxir.Gateway.Session

  def start_link(options) do
    Supervisor.start_link(__MODULE__, options)
  end

  def init(%Sharder{shard_count: shard_count, session_options: session_options}) do
    children =
      for index <- 1..shard_count do
        shard = [index - 1, shard_count]
        options = %{session_options | shard: shard}
        session_spec = Session.child_spec(options)
        %{session_spec | id: index - 1}
      end

    options = [
      strategy: :one_for_one
    ]

    Supervisor.init(children, options)
  end
end
