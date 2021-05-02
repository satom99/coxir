defmodule Coxir do
  @moduledoc """
  Work in progress.
  """
  use Application

  alias Coxir.{Limiter, Storage, Voice}

  def start(_type, _args) do
    children = [
      Limiter,
      Storage,
      Voice
    ]

    options = [
      strategy: :one_for_one,
      name: __MODULE__
    ]

    Supervisor.start_link(children, options)
  end
end
