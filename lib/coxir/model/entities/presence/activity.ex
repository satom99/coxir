defmodule Coxir.Presence.Activity do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model, storable?: false

  @primary_key false

  @derive Jason.Encoder

  @type t :: %Activity{}

  embedded_schema do
    field(:name, :string)
    field(:type, :integer)
    field(:url, :string)
    field(:created_at, :utc_datetime)
    field(:application_id, Snowflake)
    field(:details, :string)
    field(:state, :string)
    field(:instance, :boolean)
    field(:flags, :integer)
  end
end
