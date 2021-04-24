defmodule Example do
  use Application

  alias Example.Bot

  def start(_type, _args) do
    children = [
      Bot
    ]

    options = [
      strategy: :one_for_one,
      name: __MODULE__
    ]

    Supervisor.start_link(children, options)
  end
end
