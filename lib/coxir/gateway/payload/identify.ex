defmodule Coxir.Payload.Identify do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Payload

  @properties %{
    "$browser" => "coxir",
    "$device" => "coxir"
  }

  embedded_schema do
    field(:token, :string)
    field(:properties, :map, default: @properties)
    field(:compress, :boolean)
    field(:large_threshold, :integer, default: 250)
    field(:shard, {:array, :integer})
    field(:intents, :integer)
  end
end
