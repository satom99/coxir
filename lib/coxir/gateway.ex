defmodule Coxir.Gateway do
  @moduledoc """
  Work in progress.
  """
  alias Coxir.API
  alias Coxir.Gateway.{Producer, Dispatcher, Consumer}
  alias Coxir.Gateway.{Intents, Session, Sharder}

  @default_options [
    sharder: Coxir.Gateway.Sharder.Default,
    intents: :non_privileged
  ]

  defmacro __using__(config) do
    quote do
      @behaviour Coxir.Gateway.Handler

      def start_link do
        Coxir.Gateway.start_link(__MODULE__, unquote(config))
      end

      def child_spec(_arg) do
        %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, []},
          restart: :permanent
        }
      end
    end
  end

  def start_link(module, config) do
    children = []
    options = [strategy: :rest_for_one]

    with {:ok, supervisor} <- Supervisor.start_link(children, options) do
      {:ok, producer} = Supervisor.start_child(supervisor, Producer)
      {:ok, dispatcher} = Supervisor.start_child(supervisor, {Dispatcher, producer})

      consumer_options = %Consumer{handler: module, dispatcher: dispatcher}
      {:ok, _consumer} = Supervisor.start_child(supervisor, {Consumer, consumer_options})

      sharder_spec = get_sharder_spec(producer, module, config)
      {:ok, _sharder} = Supervisor.start_child(supervisor, sharder_spec)
    end
  end

  defp get_sharder_spec(producer, module, config) do
    global = Application.get_all_env(:coxir)
    specific = Keyword.get(global, module, [])

    config =
      @default_options
      |> Keyword.merge(global)
      |> Keyword.merge(specific)
      |> Keyword.merge(config)

    token = Keyword.fetch!(config, :token)

    intents =
      config
      |> Keyword.fetch!(:intents)
      |> Intents.get_value()

    {gateway, shard_count} = request_gateway(token)

    session = %Session{
      token: token,
      intents: intents,
      gateway: gateway,
      producer: producer
    }

    sharder = %Sharder{
      shard_count: Keyword.get(config, :shard_count, shard_count),
      session_options: session
    }

    sharder_module = Keyword.fetch!(config, :sharder)

    {sharder_module, sharder}
  end

  defp request_gateway(token) do
    {:ok, object} = API.get("gateway/bot", token: token)
    %{"url" => "wss://" <> gateway, "shards" => shard_count} = object
    gateway = :binary.bin_to_list(gateway)
    {gateway, shard_count}
  end
end
