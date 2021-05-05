defmodule Coxir.Voice.Payload.Identify do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Voice.Payload

  embedded_schema do
    field(:server_id, Snowflake)
    field(:user_id, Snowflake)
    field(:session_id, :string)
    field(:token, :string)
  end
end
