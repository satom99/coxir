defmodule Coxir.Gateway.Payload.VoiceServerUpdate do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Gateway.Payload

  embedded_schema do
    field(:token, :string)
    field(:endpoint, :string)

    belongs_to(:guild, Guild)
  end
end
