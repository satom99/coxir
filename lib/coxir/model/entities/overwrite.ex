defmodule Coxir.Overwrite do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model

  embedded_schema do
    field(:type, :integer)
    field(:allow, :integer)
    field(:deny, :integer)

    belongs_to(:channel, Channel, primary_key: true)
  end

  def fetch({id, channel_id}, options) do
    overwrite =
      %Channel{id: channel_id}
      |> Channel.preload(:permission_overwrites, options)
      |> Map.get(:permission_overwrites)
      |> Enum.find(&(&1.id == id))

    if not is_nil(overwrite) do
      {:ok, overwrite}
    else
      {:error, 404, nil}
    end
  end

  def insert(%{id: id, channel_id: channel_id} = params, options) do
    overwrite = %Overwrite{id: id, channel_id: channel_id}
    update(overwrite, params, options)
  end

  def patch({id, channel_id}, params, options) do
    API.patch("channels/#{channel_id}/permissions/#{id}", params, options)
  end

  def drop({id, channel_id}, options) do
    API.delete("channels/#{channel_id}/permissions/#{id}", options)
  end
end
