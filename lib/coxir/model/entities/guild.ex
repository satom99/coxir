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
    case API.get("guilds/#{id}", options) do
      {:ok, object} ->
        Loader.load(Guild, object)

      _other ->
        nil
    end
  end
end
