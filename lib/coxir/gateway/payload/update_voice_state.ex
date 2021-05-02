defmodule Coxir.Payload.UpdateVoiceState do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Payload

  embedded_schema do
    field(:self_mute, :boolean)
    field(:self_deaf, :boolean)

    belongs_to(:guild, Guild)
    belongs_to(:channel, Channel)
  end
end
