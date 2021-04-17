defmodule Coxir.User do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model

  embedded_schema do
    field(:username, :string)
    field(:discriminator, :string)

    has_many(:guilds, Guild, foreign_key: :owner_id)
  end

  def fetch(id, options) do
    case API.get("users/#{id}", options) do
      {:ok, object} ->
        Loader.load(User, object)

      _other ->
        nil
    end
  end
end
