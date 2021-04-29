defmodule Coxir.Gateway do
  @moduledoc """
  Work in progress.
  """
  import Supervisor, only: [start_child: 2]

  alias Coxir.{API, Sharder}
  alias Coxir.Gateway.{Producer, Dispatcher, Consumer}
  alias Coxir.Gateway.{Intents, Session}

  @default_config [
    sharder: Sharder.Default,
    intents: :non_privileged
  ]

  defmacro __using__(config) do
    quote do
      @behaviour Coxir.Gateway.Handler

      def start_link(runtime \\ []) do
        specific = Application.get_env(:coxir, __MODULE__, [])

        unquote(config)
        |> Keyword.merge(specific)
        |> Keyword.merge(runtime)
        |> Keyword.put_new(:handler, __MODULE__)
        |> Coxir.Gateway.start_link()
      end

      def child_spec(runtime) do
        %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, [runtime]},
          restart: :permanent
        }
      end
    end
  end

  def start_link(config) do
    children = []
    options = [strategy: :rest_for_one]
    handler = Keyword.fetch!(config, :handler)

    with {:ok, supervisor} <- Supervisor.start_link(children, options) do
      {:ok, producer} = start_child(supervisor, Producer)
      {:ok, dispatcher} = start_child(supervisor, {Dispatcher, producer})

      consumer_options = %Consumer{handler: handler, dispatcher: dispatcher}
      {:ok, _consumer} = start_child(supervisor, {Consumer, consumer_options})

      sharder_spec = get_sharder_spec(producer, config)
      {:ok, _sharder} = start_child(supervisor, sharder_spec)

      {:ok, supervisor}
    end
  end

  defp get_sharder_spec(producer, config) do
    global = Application.get_all_env(:coxir)

    config =
      @default_config
      |> Keyword.merge(global)
      |> Keyword.merge(config)

    token = Keyword.fetch!(config, :token)

    intents =
      config
      |> Keyword.fetch!(:intents)
      |> Intents.get_value()

    {gateway, shard_count} = request_gateway(token)

    session_options = %Session{
      token: token,
      intents: intents,
      gateway: gateway,
      producer: producer
    }

    sharder_options = %Sharder{
      shard_count: Keyword.get(config, :shard_count, shard_count),
      session_options: session_options
    }

    sharder_module = Keyword.fetch!(config, :sharder)

    {sharder_module, sharder_options}
  end

  defp request_gateway(token) do
    {:ok, object} = API.get("gateway/bot", token: token)
    %{"url" => "wss://" <> gateway, "shards" => shard_count} = object
    gateway = :binary.bin_to_list(gateway)
    {gateway, shard_count}
  end
end
