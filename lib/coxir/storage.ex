defmodule Coxir.Storage do
  @moduledoc """
  Work in progress.
  """
  alias Coxir.{Model, Snowflake}

  @callback child_spec(term) :: Supervisor.child_spec()

  @callback put(Model.t()) :: Model.t()

  @callback all(Model.t()) :: list(Model.t())

  @callback get(Model.t(), Snowflake.t()) :: Model.t() | nil

  @callback delete(Model.t()) :: Model.t()

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

  def get(model, primary) do
    storage().get(model, primary)
  end

  def delete(struct) do
    storage().delete(struct)
  end

  defp storage do
    Application.get_env(:coxir, :storage, Coxir.Storage.Default)
  end
end
