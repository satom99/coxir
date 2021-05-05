defmodule Coxir.Gateway do
  @moduledoc """
  Work in progress.
  """
  import Supervisor, only: [start_child: 2]
  import Bitwise

  alias Coxir.{API, Sharder, Token}
  alias Coxir.Gateway.{Producer, Dispatcher, Consumer}
  alias Coxir.Gateway.{Intents, Session}
  alias Coxir.Gateway.Payload.UpdatePresence
  alias Coxir.Model.Snowflake
  alias Coxir.{Guild, Channel}

  @default_config [
    sharder: Sharder.Default,
    intents: :non_privileged
  ]

  defmacro __using__(_options) do
    quote location: :keep do
      @behaviour Coxir.Gateway.Handler

      alias Coxir.Gateway

      def start_link do
        :coxir
        |> Application.get_env(__MODULE__, [])
        |> Keyword.put(:handler, __MODULE__)
        |> Gateway.start_link(name: __MODULE__)
      end

      def child_spec(_runtime) do
        %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, []},
          restart: :permanent
        }
      end

      def update_presence(params) do
        Gateway.update_presence(__MODULE__, params)
      end

      def update_presence(where, params) do
        Gateway.update_presence(__MODULE__, where, params)
      end
    end
  end

  @spec update_presence(pid, Enum.t()) :: :ok
  def update_presence(gateway, params) do
    shard_count = get_shard_count(gateway)

    for index <- 1..shard_count do
      :ok = update_presence(gateway, index - 1, params)
    end

    :ok
  end

  @spec update_presence(pid, Guild.t() | Channel.t() | non_neg_integer, Enum.t()) :: :ok
  def update_presence(gateway, where, params) do
    shard = get_shard(gateway, where)
    params = Map.new(params)
    payload = UpdatePresence.cast(params)
    Session.update_presence(shard, payload)
  end

  @spec get_shard(pid, Guild.t() | Channel.t() | non_neg_integer) :: pid
  def get_shard(gateway, %Guild{id: id}) do
    shard_count = get_shard_count(gateway)
    index = rem(id >>> 22, shard_count)
    get_shard(gateway, index)
  end

  def get_shard(gateway, %Channel{type: 1}) do
    get_shard(gateway, 0)
  end

  def get_shard(gateway, %Channel{guild_id: guild_id}) do
    guild = %Guild{id: guild_id}
    get_shard(gateway, guild)
  end

  def get_shard(gateway, index) when is_integer(index) do
    {sharder, sharder_module} = get_sharder(gateway)
    sharder_module.get_shard(sharder, index)
  end

  @spec get_user_id(pid) :: Snowflake.t()
  def get_user_id(gateway) do
    %Session{user_id: user_id} = get_session_options(gateway)
    user_id
  end

  @spec get_token(pid) :: Token.t()
  def get_token(gateway) do
    %Session{token: token} = get_session_options(gateway)
    token
  end

  def start_link(config, options \\ []) do
    handler = Keyword.fetch!(config, :handler)
    options = [{:strategy, :rest_for_one} | options]

    with {:ok, supervisor} <- Supervisor.start_link([], options) do
      {:ok, producer} = start_child(supervisor, Producer)
      {:ok, dispatcher} = start_child(supervisor, {Dispatcher, producer})

      consumer_options = %Consumer{handler: handler, dispatcher: dispatcher}
      {:ok, _consumer} = start_child(supervisor, {Consumer, consumer_options})

      sharder_spec = generate_sharder_spec(producer, config)
      {:ok, _sharder} = start_child(supervisor, sharder_spec)

      {:ok, supervisor}
    end
  end

  defp get_sharder(gateway) do
    children = Supervisor.which_children(gateway)

    Enum.find_value(
      children,
      fn {id, pid, _type, [module]} ->
        if id == :sharder, do: {pid, module}
      end
    )
  end

  defp get_shard_count(gateway) do
    %Sharder{shard_count: shard_count} = get_sharder_options(gateway)
    shard_count
  end

  defp get_session_options(gateway) do
    %Sharder{session_options: session_options} = get_sharder_options(gateway)
    session_options
  end

  defp get_sharder_options(gateway) do
    {:ok, spec} = :supervisor.get_childspec(gateway, :sharder)
    %{start: {_module, _function, [sharder_options | _rest]}} = spec
    sharder_options
  end

  defp generate_sharder_spec(producer, config) do
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

    {gateway_host, shard_count} = request_gateway_info(token)

    session_options = %Session{
      token: token,
      user_id: Token.get_user_id(token),
      intents: intents,
      producer: producer,
      gateway_host: gateway_host
    }

    sharder_options = %Sharder{
      shard_count: Keyword.get(config, :shard_count, shard_count),
      session_options: session_options
    }

    sharder_module = Keyword.fetch!(config, :sharder)

    spec = sharder_module.child_spec(sharder_options)

    %{spec | id: :sharder}
  end

  defp request_gateway_info(token) do
    {:ok, object} = API.get("gateway/bot", token: token)
    %{"url" => "wss://" <> gateway_host, "shards" => shard_count} = object
    gateway_host = :binary.bin_to_list(gateway_host)
    {gateway_host, shard_count}
  end
end
