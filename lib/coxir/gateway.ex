defmodule Coxir.Gateway do
  @moduledoc """
  Supervises the components necessary to interact with Discord's gateway.

  ### Using the module

  The module can be used with `Kernel.use/2` to transform the calling module into a gateway.

  Check out the `__using__/1` macro to see what this does exactly.
  """
  import Supervisor, only: [start_child: 2]
  import Bitwise

  alias Coxir.{API, Sharder, Token}
  alias Coxir.Gateway.Payload.{GatewayInfo, RequestGuildMembers, UpdatePresence}
  alias Coxir.Gateway.{Producer, Dispatcher, Consumer, Handler}
  alias Coxir.Gateway.{Intents, Session}
  alias Coxir.Model.Snowflake
  alias Coxir.{Guild, Channel}

  @default_config [
    sharder: Sharder.Default,
    intents: :non_privileged
  ]

  @typedoc """
  A gateway process.
  """
  @type gateway :: Supervisor.supervisor()

  @typedoc """
  The configuration that must be passed to `start_link/2`.

  If no `token` is provided, one is expected to be configured as `:token` under the `:coxir` app.

  If no `shard_count` is provided, the value suggested by Discord will be used.
  """
  @type config :: [
          token: Token.t() | none,
          intents: Intents.intents() | :non_privileged,
          shard_count: non_neg_integer | none,
          sharder: Sharder.t() | Sharder.Default,
          handler: Handler.handler()
        ]

  @doc """
  Defines functions in order to transform the calling module into a gateway.

  Defines `child_spec/1` and `start_link/0` so that the module can be added to a supervisor.

  Note that the `t:gateway/0` process that the second function starts is named after the module.

  Defines `get_user_id/0` which delegates to `get_user_id/1`.

  Defines `update_presence/1` which delegates to `update_presence/2`.

  Defines `update_presence/2` which delegates to `update_presence/3`.

  Requires the `Coxir.Gateway.Handler` behaviour to be implemented for handling events.

  Custom configuration can be given for this module by configuring it under the `:coxir` app.
  """
  defmacro __using__(_options) do
    quote location: :keep do
      @behaviour Coxir.Gateway.Handler

      alias Coxir.Gateway

      def child_spec(_runtime) do
        %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, []},
          restart: :permanent
        }
      end

      def start_link do
        :coxir
        |> Application.get_env(__MODULE__, [])
        |> Keyword.put(:handler, __MODULE__)
        |> Gateway.start_link(name: __MODULE__)
      end

      def get_user_id do
        Gateway.get_user_id(__MODULE__)
      end

      def update_presence(params) do
        Gateway.update_presence(__MODULE__, params)
      end

      def update_presence(where, params) do
        Gateway.update_presence(__MODULE__, where, params)
      end
    end
  end

  @doc """
  Calls `update_presence/3` on all the shards of a given gateway.
  """
  @spec update_presence(gateway, Enum.t()) :: :ok
  def update_presence(gateway, params) do
    shard_count = get_shard_count(gateway)

    for index <- 1..shard_count do
      :ok = update_presence(gateway, index - 1, params)
    end

    :ok
  end

  @doc """
  Updates the presence on a given channel, guild or specific shard.

  The possible parameters are the fields of `t:Coxir.Gateway.Payload.UpdatePresence.t/0`.
  """
  @spec update_presence(gateway, Channel.t() | Guild.t() | non_neg_integer, Enum.t()) :: :ok
  def update_presence(gateway, where, params) do
    shard = get_shard(gateway, where)
    params = Map.new(params)
    payload = UpdatePresence.cast(params)
    Session.update_presence(shard, payload)
  end

  @doc """
  Requests members for a given guild.

  The possible parameters are the fields of `t:Coxir.Gateway.Payload.RequestGuildMembers.t/0`.
  """
  @spec request_guild_members(gateway, Guild.t(), Enum.t()) :: :ok
  def request_guild_members(gateway, %Guild{id: guild_id} = guild, params) do
    shard = get_shard(gateway, guild)

    params =
      params
      |> Map.new()
      |> Map.put(:guild_id, guild_id)

    payload = RequestGuildMembers.cast(params)
    Session.request_guild_members(shard, payload)
  end

  @doc """
  Returns the session process for a given channel, guild or specific shard.
  """
  @spec get_shard(gateway, Channel.t() | Guild.t() | non_neg_integer) :: Session.session()
  def get_shard(gateway, %Channel{guild_id: nil}) do
    get_shard(gateway, 0)
  end

  def get_shard(gateway, %Channel{guild_id: guild_id}) do
    guild = %Guild{id: guild_id}
    get_shard(gateway, guild)
  end

  def get_shard(gateway, %Guild{id: id}) do
    shard_count = get_shard_count(gateway)
    index = rem(id >>> 22, shard_count)
    get_shard(gateway, index)
  end

  def get_shard(gateway, index) when is_integer(index) do
    {sharder, sharder_module} = get_sharder(gateway)
    sharder_module.get_shard(sharder, index)
  end

  @doc """
  Returns the id of the user the given gateway is running for.
  """
  @spec get_user_id(gateway) :: Snowflake.t()
  def get_user_id(gateway) do
    %Session{user_id: user_id} = get_session_options(gateway)
    user_id
  end

  @doc """
  Returns the token configured for the given gateway.
  """
  @spec get_token(gateway) :: Token.t()
  def get_token(gateway) do
    %Session{token: token} = get_session_options(gateway)
    token
  end

  @doc """
  Returns the `t:Coxir.Gateway.Producer.producer/0` process of a given gateway.
  """
  @spec get_producer(gateway) :: Producer.producer()
  def get_producer(gateway) do
    children = Supervisor.which_children(gateway)

    Enum.find_value(
      children,
      fn {_id, pid, _type, [module]} ->
        if module == Producer, do: pid
      end
    )
  end

  @doc """
  Starts a gateway with the given configuration and options.
  """
  @spec start_link(config, list(Supervisor.option() | Supervisor.init_option())) ::
          Supervisor.on_start()
  def start_link(config, options \\ []) do
    handler = Keyword.fetch!(config, :handler)
    options = [{:strategy, :rest_for_one} | options]

    with {:ok, gateway} <- Supervisor.start_link([], options) do
      {:ok, producer} = start_child(gateway, Producer)

      {:ok, dispatcher} = start_child(gateway, {Dispatcher, producer})

      consumer_options = %Consumer{handler: handler, dispatcher: dispatcher}
      {:ok, _consumer} = start_child(gateway, {Consumer, consumer_options})

      sharder_spec = generate_sharder_spec(producer, config)
      {:ok, _sharder} = start_child(gateway, sharder_spec)

      {:ok, gateway}
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

    token = Token.from_options!(config)

    intents =
      config
      |> Keyword.fetch!(:intents)
      |> Intents.get_value()

    {gateway_host, shard_count, _start_limit} = request_gateway_info(token)

    session_options = %Session{
      user_id: Token.get_user_id(token),
      token: token,
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
    gateway_info = GatewayInfo.cast(object)

    %GatewayInfo{
      url: "wss://" <> gateway_host,
      shards: shard_count,
      session_start_limit: start_limit
    } = gateway_info

    gateway_host = :binary.bin_to_list(gateway_host)

    {gateway_host, shard_count, start_limit}
  end
end
