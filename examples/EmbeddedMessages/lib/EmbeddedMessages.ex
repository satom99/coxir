defmodule EmbeddedMessages do
  use Application
  use Supervisor

  require HTTPotion
  alias EmbeddedMessages.Consumer

  def start(_type, _args) do
    children = [
      worker(Consumer, [])
    ]
    options = [
      strategy: :one_for_one,
      name: __MODULE__
    ]

    Supervisor.start_link(children, options)
  end
end
