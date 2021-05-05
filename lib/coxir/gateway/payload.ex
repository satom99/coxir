defmodule Coxir.Gateway.Payload do
  @moduledoc """
  Work in progress.
  """
  alias __MODULE__

  @operations %{
    0 => :DISPATCH,
    1 => :HEARTBEAT,
    2 => :IDENTIFY,
    3 => :PRESENCE_UPDATE,
    4 => :VOICE_STATE_UPDATE,
    6 => :RESUME,
    7 => :RECONNECT,
    8 => :REQUEST_GUILD_MEMBERS,
    9 => :INVALID_SESSION,
    10 => :HELLO,
    11 => :HEARTBEAT_ACK
  }
  @codes Map.new(@operations, fn {key, value} -> {value, key} end)

  defstruct [
    :operation,
    :data,
    :sequence,
    :event,
    :user_id,
    :session
  ]

  @type t :: %Payload{}

  defmacro __using__(_options) do
    quote location: :keep do
      use Coxir.Model, storable?: false

      @derive Jason.Encoder

      def cast(object) do
        Coxir.Model.Loader.load(__MODULE__, object)
      end
    end
  end

  def cast(%{"op" => opcode, "d" => data, "s" => sequence, "t" => event}, user_id, session) do
    operation = Map.fetch!(@operations, opcode)

    %Payload{
      operation: operation,
      data: data,
      sequence: sequence,
      event: event,
      user_id: user_id,
      session: session
    }
  end

  def to_command(%Payload{operation: operation, data: data}) do
    opcode = Map.fetch!(@codes, operation)
    %{"op" => opcode, "d" => data}
  end
end
