defmodule Coxir.Storage do
  @moduledoc """
  Handles how models are cached.
  """
  alias Coxir.Model

  @callback child_spec(term) :: Supervisor.child_spec()

  @callback put(Model.instance()) :: Model.instance()

  @callback all(Model.model()) :: list(Model.instance())

  @callback all_by(Model.model(), keyword) :: list(Model.instance())

  @callback get(Model.model(), Model.key()) :: Model.instance() | nil

  @callback get_by(Model.model(), keyword) :: Model.instance() | nil

  @callback delete(Model.model(), Model.key()) :: :ok

  @callback delete_by(Model.model(), keyword) :: :ok

  defmacro __using__(_options) do
    quote location: :keep do
      @behaviour Coxir.Storage

      import Coxir.Model.Helper
    end
  end

  @doc false
  def child_spec(term) do
    storage().child_spec(term)
  end

  @doc false
  def put(struct) do
    storage().put(struct)
  end

  @doc false
  def all(model) do
    storage().all(model)
  end

  @doc false
  def all_by(model, clauses) do
    storage().all_by(model, clauses)
  end

  @doc false
  def get(model, key) do
    storage().get(model, key)
  end

  @doc false
  def get_by(model, clauses) do
    storage().get_by(model, clauses)
  end

  @doc false
  def delete(model, key) do
    storage().delete(model, key)
  end

  @doc false
  def delete_by(model, clauses) do
    storage().delete_by(model, clauses)
  end

  defp storage do
    Application.get_env(:coxir, :storage, Coxir.Storage.Default)
  end
end
