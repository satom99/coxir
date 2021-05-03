defmodule Coxir.Gateway.Payload.UpdatePresence do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Gateway.Payload

  alias Coxir.Presence.Activity

  embedded_schema do
    field(:since, :integer)
    field(:status, :string)
    field(:afk, :boolean)

    embeds_many(:activities, Activity)
  end
end
