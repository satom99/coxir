defmodule Coxir.Storage do
  @moduledoc """
  Work in progress.
  """
  alias Coxir.{Model, Snowflake}

  @callback fetch(Model.t(), Snowflake.t()) :: {:ok, Model.t()} | :error

  @callback store(struct) :: any
end
