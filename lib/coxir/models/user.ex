defmodule Coxir.Model.User do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model

  embedded_schema do
    field :username, :string
    field :discriminator, :string
    field :avatar, :string
  end
end
