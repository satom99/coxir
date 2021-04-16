defmodule Coxir.Guild do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model

  embedded_schema do
    field(:name, :string)

    belongs_to(:owner, User)
  end

  def fetch(id, options) do
    with {:ok, object} <- API.get("guilds/#{id}", options) do
      struct = Loader.load(Guild, object)
      {:ok, struct}
    end
  end
end
