defmodule Coxir.Struct.Overwrite do
  use Coxir.Struct

  def edit(%{id: id, channel: channel}, params),
    do: edit(id, channel, params)

  def edit(overwrite, channel, params) do
    API.request(:put, "channels/#{channel}/permissions/#{overwrite}", params)
  end

  def delete(%{id: id, channel: channel}),
    do: delete(id, channel)

  def delete(overwrite, channel) do
    API.request(:delete, "channels/#{channel}/permissions/#{overwrite}")
  end
end
