defmodule Coxir.Voice.Payload.Resume do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Voice.Payload

  embedded_schema do
    field(:server_id, Snowflake)
    field(:session_id, Snowflake)
    field(:token, :string)
  end
end
