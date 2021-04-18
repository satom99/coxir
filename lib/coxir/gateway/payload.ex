defmodule Coxir.Gateway.Payload do
  @moduledoc """
  Work in progress.
  """
  import Ecto.Changeset

  defmacro __using__(_options) do
    quote location: :keep do
      use Ecto.Schema

      def cast(object) do
        Coxir.Gateway.Payload.cast(__MODULE__, object)
      end
    end
  end

  def cast(payload, object) do
    fields = payload.__schema__(:fields)

    payload
    |> struct()
    |> cast(object, fields)
    |> apply_changes()
  end
end
