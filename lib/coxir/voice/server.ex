defmodule Coxir.Voice.Server do
  @moduledoc false

  use Supervisor

  alias Coxir.Voice.{Handler, Gateway, Audio}

  def start_link(state) do
    Supervisor.start_link __MODULE__, state
  end

  def init(state) do
    state = state
    |> Map.merge(
      %{
        server: self()
      }
    )
    children = [
      worker(Handler, [state])
    ]
    options = [
      strategy: :rest_for_one
    ]
    Supervisor.init(children, options)
  end

  def update(server, data) do
    server
    |> get_handler
    |> send({:update, data})
  end

  def get_handler(server) do
    server
    |> get_child(Handler)
  end
  def get_gateway(server) do
    server
    |> get_child(Gateway)
  end
  def get_audio(server) do
    server
    |> get_child(Audio)
  end

  def start_child(server, module, state) do
    child = worker(module, [state])
    server
    |> Supervisor.start_child(child)
    |> case do
      {:ok, pid} ->
        pid
      _error ->
        nil
    end
  end

  defp get_child(server, module) do
    server
    |> Supervisor.which_children
    |> Enum.find(
      fn {_id, _pid, _type, [mod]} ->
        mod == module
      end
    )
    |> case do
      {_id, pid, _type, _modules} ->
        pid
      _none ->
        nil
    end
  end
end
