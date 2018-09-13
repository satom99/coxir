defmodule Coxir.Stage.Consumer do
  @moduledoc false

  use GenStage

  alias Coxir.Stage

  def start_link(handler) do
    state = %{
      handler: handler,
      public: []
    }
    GenStage.start_link(__MODULE__, state)
  end

  def init(state) do
    {:consumer, state, subscribe_to: Stage.middles()}
  end

  def handle_events(events, _from, %{handler: handler, public: public} = state) do
    public = handle(handler, events, public)
    {:noreply, [], %{state | public: public}, :hibernate}
  end

  def handle(_handler, [], state), do: state
  def handle(handler, [event | events], state) do
    handler
    |> apply(:handle_event, [event, state])
    |> case do
      {:ok, state} ->
        handle(handler, events, state)
      term ->
        raise "Expected {:ok, state}, got #{inspect term}"
    end
  end
end
