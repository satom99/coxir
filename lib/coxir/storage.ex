defmodule Coxir.Storage do
  @moduledoc """
  Work in progress.
  """
  alias Coxir.{Model, Snowflake}

  @callback get(Model.t(), Snowflake.t()) :: Model.t() | nil

  @callback put(Model.t()) :: term

  defmacro __using__(_options) do
    quote do
      @behaviour Coxir.Storage
    end
  end
end
