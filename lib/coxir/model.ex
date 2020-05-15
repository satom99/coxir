defmodule Coxir.Model do
  @moduledoc """
  Work in progress.
  """
  @type t :: module

  defmacro __using__(_options) do
    quote location: :keep do
      use Ecto.Schema

      alias Coxir.Snowflake
      alias Coxir.Model.{User, Guild, Channel, Message}

      @primary_key {:id, Snowflake, []}
    end
  end
end
