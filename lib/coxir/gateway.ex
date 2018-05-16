defmodule Coxir.Gateway do
  @moduledoc """
  In charge of supervising all the shards,
  provides methods to interact with them.
  """

  use Supervisor

  alias Coxir.API
  alias Coxir.Gateway.Worker

  @doc false
  def start_link do
    token = Coxir.token

    %{url: gateway, shards: shards} = API.request(:get, "gateway/bot")

    shards = Application.get_env(:coxir, :shards, shards)

    children = for index <- 1..shards do
      state = %{
        token: token,
        shard: [index - 1, shards],
        gateway: gateway <> "/?v=6&encoding=json"
      }
      worker(Worker, [state], [id: index - 1])
    end
    options = [
      strategy: :one_for_one,
      name: __MODULE__
    ]
    Supervisor.start_link(children, options)
  end

  @doc false
  def child_spec(arg),
    do: super(arg)

  def set_status(pid, status, game) do
    {since, afk} = status
    |> case do
      "idle" -> {1, true}
      _other -> {0, false}
    end
    data = %{
      game: game,
      status: status,
      since: since,
      afk: afk
    }
    send(pid, 3, data)
  end
  def set_status(status, game) do
    __MODULE__
    |> Supervisor.which_children
    |> Enum.map(
      fn {_id, pid, _type, _modules} ->
        set_status(pid, status, game)
      end
    )
  end

  @doc false
  def send(pid, opcode, data) do
    Kernel.send(pid, {:send, opcode, data})
  end

  @doc false
  def get(shard) do
    __MODULE__
    |> Supervisor.which_children
    |> Enum.find(
      fn {id, _pid, _type, _modules} ->
        id == shard
      end
    )
    |> elem(1)
  end
end
