defmodule Coxir.API.Limiter do
  @moduledoc """
  Responsible for handling ratelimits.
  """
  alias Coxir.Limiter

  alias Tesla.Middleware.Retry

  @behaviour Tesla.Middleware

  @major_params ["guilds", "channels", "webhooks"]
  @regex ~r|/?([\w-]+)/(?:\d+)|i

  @header_global "x-ratelimit-global"
  @header_remaining "x-ratelimit-remaining"
  @header_reset "x-ratelimit-reset"

  def call(env, next, options) do
    bucket = bucket_name(env)

    with :ok <- Limiter.hit(:global),
         :ok <- Limiter.hit(bucket) do
      continue_call(bucket, env, next)
    else
      {:error, timeout} ->
        Process.sleep(timeout)
        call(env, next, options)
    end
  end

  defp continue_call(bucket, env, next) do
    with {:ok, response} <- run_request(env, next) do
      global = Tesla.get_header(response, @header_global)
      remaining = Tesla.get_header(response, @header_remaining)
      reset = Tesla.get_header(response, @header_reset)

      if remaining && reset do
        remaining = String.to_integer(remaining)
        reset = String.to_integer(reset) * 1000
        bucket = if global, do: :global, else: bucket
        Limiter.put(bucket, remaining, reset)
      end

      {:ok, response}
    end
  end

  defp run_request(env, next) do
    options = [should_retry: &should_retry/1]
    Retry.call(env, next, options)
  end

  defp should_retry(response) do
    case response do
      {:ok, %{status: 429}} ->
        IO.inspect(:should_retry)

        true

      _other ->
        false
    end
  end

  defp bucket_name(%{method: method, url: url}) do
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
  end
end
