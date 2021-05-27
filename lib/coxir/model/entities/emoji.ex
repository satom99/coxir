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

  def format(%Emoji{id: nil, name: name}) do
    name
  end

  def format(%Emoji{id: id, name: name}) do
    "#{name}:#{id}"
  end
end
