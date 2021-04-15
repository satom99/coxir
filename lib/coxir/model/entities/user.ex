defmodule Coxir.User do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model

  embedded_schema do
    field(:username, :string)
    field(:discriminator, :string)
    field(:avatar, :string)

    has_many(:guilds, Guild, foreign_key: :owner_id)
  end

  def fetch(snowflake, options) do
    response = API.get("users/#{snowflake}", options)
    Loader.cast(User, response)
  end
end
