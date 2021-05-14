defmodule Coxir.Gateway.Payload.VoiceInstanceUpdate do
  @moduledoc """
  Work in progress.
  """
  alias Coxir.Model.Snowflake
  alias Coxir.Voice.Instance

  @type t :: %__MODULE__{
          instance: Instance.instance(),
          user_id: Snowflake.t(),
          guild_id: Snowflake.t() | nil,
          channel_id: Snowflake.t(),
          has_player?: boolean,
          invalid?: boolean,
          playing?: boolean
        }

  defstruct [
    :instance,
    :user_id,
    :guild_id,
    :channel_id,
    :has_player?,
    :invalid?,
    :playing?
  ]
end
