defmodule Coxir.Storage do
  @moduledoc """
  Work in progress.
  """
  alias Coxir.{Model, Snowflake}

  @callback child_spec(term) :: Supervisor.child_spec()

  @callback put(Model.object()) :: Model.object()

  @callback all(Model.name()) :: list(Model.object())

  @callback select(Model.name(), Keyword.t()) :: list(Model.object())

  @callback get(Model.name(), Snowflake.t()) :: Model.object() | nil

  @callback get_by(Model.name(), Keyword.t()) :: Model.object() | nil

  @callback delete(Model.object()) :: Model.object()

  defmacro __using__(_options) do
    quote location: :keep do
      @behaviour Coxir.Storage

      import Coxir.Storage.Helper
    end
  end

  def child_spec(term) do
    storage().child_spec(term)
  end

  def put(struct) do
    storage().put(struct)
  end

  def all(model) do
    storage().all(model)
  end

  def select(model, clauses) do
    storage().select(model, clauses)
  end

  def get(model, primary) do
    storage().get(model, primary)
  end

  def get_by(model, clauses) do
    storage().get_by(model, clauses)
  end

  def delete(struct) do
    storage().delete(struct)
  end

  defp storage do
    Application.get_env(:coxir, :storage, Coxir.Storage.Default)
  end
end
