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

  @callback delete(Model.t()) :: Model.t()

  @optional_callbacks [preload: 2]

  def child_spec(term) do
    storage().child_spec(term)
  end

  def put(model) do
    storage().put(model)
  end

  def all(model) do
    storage().all(model)
  end

  def get(model, primary) do
    storage().get(model, primary)
  end
  end

  def preload(model) do
    storage().preload(model)
  end

  defp storage do
    Application.get_env(:coxir, :storage, Coxir.Storage.Default)
  end
end
