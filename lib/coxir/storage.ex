defmodule Coxir.Storage do
  @moduledoc """
  Work in progress.
  """
  alias Coxir.{Model, Snowflake}

  @callback put(Model.t()) :: Model.t()

  @callback all(Model.t()) :: list(Model.t())

  @callback get(Model.t(), Snowflake.t()) :: Model.t() | nil

  @callback preload(Model.t(), Keyword.t()) :: Model.t()

  @callback start_link() :: GenServer.on_start()

  @optional_callbacks [start_link: 0]
end
