defmodule Coxir.API.RateLimiter do
  @moduledoc """
  Responsible for handling ratelimits.
  """
  @behaviour Tesla.Middleware

  import Coxir.Limiter.Helper
  import Coxir.API.Helper

  alias Coxir.{Limiter, Token}

  @major_params ["guilds", "channels", "webhooks"]
  @regex ~r|/?([\w-]+)/(?:\d+)|i

  @header_remaining "x-ratelimit-remaining"
  @header_reset "x-ratelimit-reset"
  @header_global "x-ratelimit-global"
  @header_retry "retry-after"
  @header_date "date"

  def call(request, next, options) do
    bucket = get_bucket(request)

    :ok = wait_hit(:global)
    :ok = wait_hit(bucket)

    with {:ok, %{status: status} = response} <- Tesla.run(request, next) do
      update_bucket(bucket, response)

      if status == 429 do
        call(request, next, options)
      else
        {:ok, response}
      end
    end
  end

  defp update_bucket(bucket, response) do
    global = Tesla.get_header(response, @header_global)
    remaining = Tesla.get_header(response, @header_remaining)
    reset = Tesla.get_header(response, @header_reset)
    retry = Tesla.get_header(response, @header_retry)
    date = Tesla.get_header(response, @header_date)

    remaining = if remaining, do: String.to_integer(remaining)
    reset = if reset, do: String.to_integer(reset) * 1000
    retry = if retry, do: String.to_integer(retry) * 1000

    if reset || retry do
      remaining = if remaining, do: remaining, else: 0
      reset = if reset, do: reset, else: time_now() + retry

      bucket = if global, do: :global, else: bucket

      remote = unix_from_date(date)
      latency = abs(time_now() - remote)

      Limiter.put(bucket, remaining, reset + latency)
    end
  end

  defp unix_from_date(header) do
    header
    |> String.to_charlist()
    |> :httpd_util.convert_request_date()
    |> :calendar.datetime_to_gregorian_seconds()
    |> :erlang.-(62_167_219_200)
    |> :erlang.*(1000)
  end

  defp get_bucket(%{method: method, url: url} = request) do
    snowflake =
      request
      |> get_token()
      |> Token.get_snowflake()

    bucket =
      case Regex.run(@regex, url) do
        [route, param] when param in @major_params ->
          if method == :delete and String.contains?(url, "messages") do
            "delete:" <> route
          else
            route
          end

        _other ->
          url
      end

    "#{snowflake}:#{bucket}"
  end
end
