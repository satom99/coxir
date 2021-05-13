defmodule Coxir.Gateway.Payload.VoiceInstanceUpdate do
  @moduledoc """
  Work in progress.
  """
  alias Coxir.Model.Snowflake
  alias Coxir.Voice.Instance

  @type t :: %__MODULE__{
          instance: Instance.instance(),
          guild_id: Snowflake.t() | nil,
          channel_id: Snowflake.t(),
          invalid?: boolean,
          playing?: boolean
        }

  defstruct [
    :instance,
    :guild_id,
    :channel_id,
    {:invalid?, false},
    {:playing?, false}
  ]
end
