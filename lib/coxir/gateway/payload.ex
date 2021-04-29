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
    :session
  ]

  @type t :: %__MODULE__{}

  defmacro __using__(_options) do
    quote location: :keep do
      use Ecto.Schema

      import Ecto.Changeset

      @derive Jason.Encoder

      @primary_key false

      @type t :: %__MODULE__{}

      def cast(object) do
        fields = __schema__(:fields)

        __MODULE__
        |> struct()
        |> cast(object, fields)
        |> apply_changes()
      end
    end
  end

  def cast(%{"op" => opcode, "d" => data, "s" => sequence, "t" => event}) do
    operation = Map.fetch!(@operations, opcode)
    %Payload{operation: operation, data: data, sequence: sequence, event: event, session: self()}
  end

  def to_command(%Payload{operation: operation, data: data}) do
    opcode = Map.fetch!(@codes, operation)
    %{"op" => opcode, "d" => data}
  end
end
