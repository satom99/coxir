defmodule Coxir do
  @moduledoc """
  Entry-point for the coxir application.

  Starts a supervisor with the components required by the library.
  """
  use Application

  alias Coxir.{Limiter, Storage, Voice}

  @doc false
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
