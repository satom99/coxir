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

    reset = if reset, do: string_to_float(reset) * 1000
    retry = if retry, do: string_to_float(retry) * 1000

    reset = if reset, do: round(reset)
    retry = if retry, do: round(retry)

    if reset || retry do
      bucket = if global, do: :global, else: bucket

      remaining = if remaining, do: remaining, else: 0

      reset = if reset, do: reset, else: time_now() + retry

      remote = unix_from_date(date)
      latency = abs(time_now() - remote)

      Limiter.put(bucket, remaining, reset + latency)
    end
  end

  defp string_to_float(string) do
    {float, _rest} = Float.parse(string)
    float
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
    user_id =
      request
      |> get_token()
      |> Token.get_user_id()

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

    "#{user_id}:#{bucket}"
  end
end
