defmodule Coxir.API.Error do
  @moduledoc """
  Work in progress.
  """
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false

  @type t :: %__MODULE__{}

  embedded_schema do
    field(:code, :integer)
    field(:message, :string)
  end

  def cast(object) do
    fields = __schema__(:fields)

    %__MODULE__{}
    |> cast(object, fields)
    |> apply_changes()
  end
end
