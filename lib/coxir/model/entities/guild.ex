defmodule Coxir.Guild do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model

  embedded_schema do
    field(:name, :string)

    belongs_to(:owner, User)
  end
end
