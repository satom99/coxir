defmodule Coxir.Gateway.Handler do
  @moduledoc """
  Behaviour for modules handling events from `Coxir.Gateway.Consumer`.
  """
  alias Coxir.Gateway.Dispatcher

  @typedoc """
  A module that implements the behaviour.
  """
  @type t :: module

  @doc """
  Called when a `t:Coxir.Gateway.Dispatcher.event/0` is to be handled.
  """
  @callback handle_event(Dispatcher.event()) :: any

  @doc false
  def child_spec(handler) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_handler, [handler]},
      restart: :temporary
    }
  end

  @doc false
  def start_handler(handler, event) do
    Task.start_link(fn ->
      handler.handle_event(event)
    end)
  end
end
