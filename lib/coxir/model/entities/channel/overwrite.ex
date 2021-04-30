defmodule Coxir.Channel.Overwrite do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model

  embedded_schema do
    field(:type, :integer)
    field(:allow, :integer)
    field(:deny, :integer)
  end
end
