defmodule Coxir do
  @moduledoc """
  Work in progress.
  """
  use Application

  alias Coxir.{Storage, Limiter}

  def start(_type, _args) do
    children = [
      Storage,
      Limiter
    ]

    options = [
      strategy: :one_for_one,
      name: __MODULE__
    ]

    Supervisor.start_link(children, options)
  end
end
