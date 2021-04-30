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
end
