defmodule Coxir.Stage do
  @moduledoc false

  use Supervisor

  alias Coxir.Stage.{Producer, Middle}

  @limit System.schedulers_online()

  def start_link do
    children = [
      worker(Producer, []),
      worker(Middle, [], [id: 1])
    ]
    options = [
      strategy: :one_for_one,
      name: __MODULE__
    ]
    Supervisor.start_link(children, options)
  end

  def middles, do: get_children(Middle)

  defp get_children(module) do
    __MODULE__
    |> Supervisor.which_children
    |> Enum.filter(
      fn {_id, _pid, _type, [mod]} ->
        mod == module
      end
    )
    |> Enum.map(& elem(&1, 1))
  end
end
