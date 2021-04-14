defmodule Coxir.Storage do
  @moduledoc """
  Work in progress.
  """
  alias Coxir.{Model, Snowflake}

  @callback child_spec(term) :: Supervisor.child_spec()

  @callback put(Model.t()) :: Model.t()

  @callback all(Model.t()) :: list(Model.t())

  @callback get(Model.t(), Snowflake.t()) :: Model.t() | nil

  @callback preload(Model.t(), Keyword.t()) :: Model.t()

  @optional_callbacks [preload: 2]
end
