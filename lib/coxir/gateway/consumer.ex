defmodule Coxir.Consumer do
  @moduledoc """
  Work in progress.
  """
  @type event :: tuple

  @type state :: map

  @callback handle_event(event, state) :: {:ok, state}
end
