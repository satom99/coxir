defmodule Coxir.Model do
  @moduledoc """
  Work in progress.
  """
  defmacro __using__(_options) do
    quote location: :keep do
      use Ecto.Schema

      alias Coxir.Snowflake
      alias Coxir.Model.{User, Guild, Channel}

      @primary_key {:id, Snowflake, []}
    end
  end
end
