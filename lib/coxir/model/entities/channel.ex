defmodule Coxir.Channel do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model

  embedded_schema do
    field(:name, :string)
    field(:topic, :string)
    field(:bitrate, :integer)
    field(:user_limit, :integer)
    field(:rate_limit_per_user, :integer)
    field(:icon, :string)

    belongs_to(:owner, User)
    belongs_to(:guild, Guild)
    belongs_to(:parent, Channel)
  end

  def fetch(id, options) do
    with {:ok, object} <- API.get("channels/#{id}", options) do
      struct = Loader.load(Channel, object)
      {:ok, struct}
    end
  end
end
