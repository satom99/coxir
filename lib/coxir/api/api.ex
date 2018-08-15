defmodule Coxir.API do
  @moduledoc """
  Used to interact with Discord's API while
  keeping track of all the ratelimits.
  """

  alias Coxir.API.Base

  @table :rates
  @major_parameters ["guilds", "channels", "webhooks"]

  @doc false
  def create_tables do
    :ets.new @table, [:set, :public, :named_table]
  end

  @doc """
  Performs an API request.

  Returns raw data, the atom `:ok`
  or a map containing error information.
  """
  @spec request(atom, String.t, String.t, Keyword.t, Keyword.t) :: :ok | map

  def request(method, path, body \\ "", options \\ [], headers \\ []) do
    route = path
    |> router(method)

    route
    |> route_limit
    |> case do
      nil ->
        Base.request(method, path, body, headers, options)
        |> response(route)
      limit ->
        Process.sleep(limit)
        request(method, path, body, options, headers)
    end
  end

  @doc """
  Performs a multipart API request.

  Refer to `request/5` for more information.
  """
  @spec request_multipart(atom, String.t, Keyword.t, Keyword.t, Keyword.t) :: :ok | map

  def request_multipart(method, path, body, options \\ [], headers \\ []) do
    body = body
    |> Enum.to_list
    body = {:multipart, body}

    headers = [
      {"Content-Type", "multipart/form-data"}
      | headers
    ]
    request(method, path, body, options, headers)
  end

  defp response({_atom, struct}, route) do
    struct
    |> case do
      %{body: body, headers: headers, status_code: code} ->
        reset = headers["X-RateLimit-Reset"]
        remaining = headers["X-RateLimit-Remaining"]

        {final, reset, remaining} = \
        headers["X-RateLimit-Global"]
        |> case do
          nil ->
            {route, reset, remaining}
          _global ->
            retry = headers["Retry-After"]
            reset = current_time() + retry
            {:global, reset, 0}
        end

        if reset && remaining do
          remote = headers["Date"]
          |> date_header

          offset = (remote - current_time())
          |> abs

          {final, remaining, reset + offset}
          |> update_limit
        end

        cond do
          final != route ->
            unlock(route)
          !(reset && remaining) ->
            unlock(route)
          true ->
            :ignore
        end

        cond do
          code in [204] ->
            :ok
          code in [200, 201, 304] ->
            body
          true ->
            %{error: body, code: code}
        end
      %{reason: reason} ->
        unlock(route)
        %{error: reason}
    end
  end

  defp router(path, method) do
    ~r|/?([\w-]+)/(?:\d+)|i
    |> Regex.run(path)
    |> case do
      [route, param] when param in @major_parameters ->
        cond do
          String.contains?(final, "messages") and method == :delete ->
            "#{method}:#{path}"
          true ->
            route
        end
      _other ->
        path
    end
  end

  defp route_limit(route) do
    ignore = \
    reset(:global)
    |> case do
      0 -> reset(route)
      n -> n
    end

    remaining = \
    count(:global)
    |> case do
      false -> count(route)
      other -> other
    end

    cond do
      ignore > 0 ->
        nil
      remaining > -1 ->
        nil
      true ->
        250
    end
  end

  defp count(route) do
    arguments = \
    [@table, route, {2, -1}]

    arguments = \
    case route do
      :global ->
        arguments
      _other ->
        tuple = {route, 1, :lock}
        arguments ++ [tuple]
    end

    try do
      apply(:ets, :update_counter, arguments)
    rescue
      _ -> false
    end
  end

  defp reset(route) do
    return = \
    case route do
      :global ->
        {:"$1", nil, 0}
      _other ->
        {:"$1", 0, :lock}
    end

    fun = \
    [{
      {:"$1", :"$2", :"$3"},
      [{
        :andalso,
        {:==, :"$1", route},
        {:"/=", :"$3", :lock},
        {:<, {:-, :"$3", current_time()}, 0}
      }],
      [{return}]
    }]

    :ets.select_replace(@table, fun)
  end

  defp unlock(route) do
    fun = \
    [{
      {:"$1", :"$2", :"$3"},
      [{
        :andalso,
        {:==, :"$1", route},
        {:==, :"$3", :lock}
      }],
      [{
        {:"$1", 1, :"$3"}
      }]
    }]

    :ets.select_replace(@table, fun)
  end

  defp update_limit({route, remaining, reset}) do
    fun = \
    [{
      {:"$1", :"$2", :"$3"},
      [{
        :andalso,
        {:==, :"$1", route},
        {:==, :"$3", :lock}
      }],
      [{
        {:"$1", remaining, reset}
      }]
    }]

    :ets.select_replace(@table, fun)
  end

  defp current_time do
    DateTime.utc_now
    |> DateTime.to_unix(:milliseconds)
  end

  defp date_header(header) do
    header
    |> String.to_charlist
    |> :httpd_util.convert_request_date
    |> :calendar.datetime_to_gregorian_seconds
    |> :erlang.-(62_167_219_200)
    |> :erlang.*(1000)
  end
end
