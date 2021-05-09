defmodule Coxir.Webhook do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model

  embedded_schema do
    field(:type, :integer)
    field(:name, :string)
    field(:avatar, :string)
    field(:token, :string)

    belongs_to(:channel, Channel)
    belongs_to(:guild, Guild)
    belongs_to(:user, User)
    belongs_to(:source_guild, Guild)
    belongs_to(:source_channel, Channel)
  end

  def insert(%{channel_id: channel_id} = params, options) do
    API.post("channels/#{channel_id}/webhooks", params, options)
  end
end
