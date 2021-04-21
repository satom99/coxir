defmodule Coxir.Gateway.Payload.Identify do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Gateway.Payload

  embedded_schema do
    field(:token, :string)
    field(:compress, :boolean)
    field(:large_threshold, :integer, default: 250)
    field(:shard, {:array, :integer})
    field(:intents, :integer)

    embeds_one :properties, Properties do
      field(:"$browser", :string)
      field(:"$device", :string)
    end
  end
end
