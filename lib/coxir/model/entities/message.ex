defmodule Coxir.Message do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model

  embedded_schema do
    field(:content, :string)
    field(:timestamp, :utc_datetime)
    field(:edited_timestamp, :utc_datetime)

    belongs_to(:channel, Channel)
    belongs_to(:guild, Guild)
    belongs_to(:author, User)
  end

  def fetch(snowflake) do
    %Message{id: snowflake}
  end
end
