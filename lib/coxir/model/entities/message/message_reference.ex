defmodule Coxir.Message.Reference do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model

  @primary_key false

  embedded_schema do
    belongs_to(:message, Message, primary_key: true)
    belongs_to(:channel, Channel, primary_key: true)
    belongs_to(:guild, Guild)
  end
end
