defmodule Coxir.Voice.Payload do
  @moduledoc """
  Work in progress.
  """
  alias __MODULE__

  @operations %{
    0 => :IDENTIFY,
    1 => :SELECT_PROTOCOL,
    2 => :READY,
    3 => :HEARTBEAT,
    4 => :SESSION_DESCRIPTION,
    5 => :SPEAKING,
    6 => :HEARTBEAT_ACK,
    7 => :RESUME,
    8 => :HELLO,
    9 => :RESUMED
  }
  @codes Map.new(@operations, fn {key, value} -> {value, key} end)

  defstruct [
    :operation,
    :data
  ]

  @type t :: %Payload{}

  defmacro __using__(_options) do
    quote location: :keep do
      use Coxir.Model, storable?: false

      @primary_key false

      @derive Jason.Encoder

      def cast(object) do
        Coxir.Model.Loader.load(__MODULE__, object)
      end
    end
  end

  def cast(%{"op" => opcode, "d" => data}) do
    operation = Map.get(@operations, opcode, {:UNKNOWN, opcode})
    %Payload{operation: operation, data: data}
  end

  def to_command(%Payload{operation: operation, data: data}) do
    opcode = Map.fetch!(@codes, operation)
    %{"op" => opcode, "d" => data}
  end
end
