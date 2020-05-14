defmodule Coxir.Model do
  @moduledoc """
  Work in progress.
  """
  defmacro __using__(_options) do
    quote location: :keep do
      use Ecto.Schema

      @primary_key {:id, :id, []}
    end
  end
end
