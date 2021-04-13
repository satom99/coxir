defmodule Coxir.API.Limiter do
  @moduledoc """
  Responsible for handling ratelimits.
  """
  alias Coxir.Limiter

  @behaviour Tesla.Middleware

  @header_global "X-RateLimit-Global"
  @header_remaining "X-RateLimit-Remaining"
  @header_reset "X-RateLimit-Reset"

  @major_params ["guilds", "channels", "webhooks"]
  @regex ~r|/?([\w-]+)/(?:\d+)|i

  def call(env, next, _options) do
    bucket = get_bucket(env)

    with {:error, timeout} <- Limiter.hit(:global) do
      Process.sleep(timeout)
    end

    with {:error, timeout} <- Limiter.hit(bucket) do
      Process.sleep(timeout)
    end

    with {:ok, response} <- Tesla.run(env, next) do
      global = Tesla.get_header(response, @header_global)
      remaining = Tesla.get_header(response, @header_remaining)
      reset = Tesla.get_header(response, @header_reset)

      if remaining && reset do
        bucket = if global, do: :global, else: bucket
        Limiter.put(bucket, remaining, reset)
      end

      {:ok, response}
    end
  end

  defp get_bucket(%{method: _method, url: url}) do
    case Regex.run(@regex, url) do
      [route, param] when param in @major_params ->
        route

      _other ->
        url
    end
  end
end
