defmodule Coxir.Voice.Payload.SelectProtocol do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Voice.Payload

  alias Coxir.Voice.Payload.SelectProtocol.Data

  embedded_schema do
    field(:protocol, :string, default: "udp")

    embeds_one(:data, Data)
  end
end

defmodule Coxir.Voice.Payload.SelectProtocol.Data do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Voice.Payload

  embedded_schema do
    field(:address, :string)
    field(:port, :integer)
    field(:mode, :string)
  end
end
