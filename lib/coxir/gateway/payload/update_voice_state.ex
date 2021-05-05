defmodule Coxir.Gateway.Payload.UpdateVoiceState do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Gateway.Payload

  embedded_schema do
    field(:self_mute, :boolean)
    field(:self_deaf, :boolean)

    field(:guild_id, Snowflake)
    field(:channel_id, Snowflake)
  end
end
