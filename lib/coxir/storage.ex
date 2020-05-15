defmodule Coxir.Storage do
  @moduledoc """
  Work in progress.
  """
  alias Coxir.{Model, Snowflake}

  @callback get(Model.t(), Snowflake.t()) :: Model.t() | nil

  @callback put(struct) :: any
end
