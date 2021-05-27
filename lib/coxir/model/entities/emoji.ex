defmodule Coxir.Emoji do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model, storable?: false

  @type t :: %Emoji{}

  embedded_schema do
    field(:name, :string)
    field(:roles, {:array, Snowflake})
    field(:require_colons, :boolean)
    field(:managed, :boolean)
    field(:animated, :boolean)
    field(:available, :boolean)

    belongs_to(:user, User)
  end
end
