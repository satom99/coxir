defmodule Coxir.Gateway.Payload.VoiceInstanceUpdate do
  @moduledoc """
  Work in progress.
  """
  alias Coxir.Voice.Instance

  @type t :: %__MODULE__{
          instance: Instance.instance()
        }

  defstruct [
    :instance
  ]
end
