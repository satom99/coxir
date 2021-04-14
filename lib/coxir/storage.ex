defmodule Coxir.Storage do
  @moduledoc """
  Work in progress.
  """
  alias Coxir.{Struct, Snowflake}

  @callback child_spec(term) :: Supervisor.child_spec()

  @callback put(Struct.t()) :: Struct.t()

  @callback all(Struct.t()) :: list(Struct.t())

  @callback get(Struct.t(), Snowflake.t()) :: Struct.t() | nil

  @callback delete(Struct.t()) :: Struct.t()

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

  def all(module) do
    storage().all(module)
  end

  def get(module, primary) do
    storage().get(module, primary)
  end

  def delete(struct) do
    storage().delete(struct)
  end

  defp storage do
    Application.get_env(:coxir, :storage, Coxir.Storage.Default)
  end
end
