defmodule Coxir.API.Base do
  @moduledoc false

  use HTTPoison.Base

  @project Coxir.Mixfile.project()
  @website @project[:source_url]
  @version @project[:version]
  @library @project[:name]

  def process_url(path) do
    "https://discord.com/api/" <> path
  end

  def process_request_body(""), do: ""
  def process_request_body({:multipart, _list} = body), do: body
  def process_request_body(body) do
    body
    |> Map.new
    |> Jason.encode!
  end

  def process_request_headers(headers) do
    token = Coxir.token()
    [
      {"User-Agent", "#{@library} (#{@website}, #{@version})"},
      {"Authorization", "Bot " <> token},
      {"Content-Type", "application/json"}
      | headers
    ]
  end

  def process_response_body(""), do: ""
  def process_response_body(body) do
    Jason.decode!(body, keys: :atoms)
  end

  def process_headers(headers) do
    headers
    |> Map.new
    |> Map.update("Retry-After", nil, &String.to_integer/1)
    |> Map.update("X-RateLimit-Remaining", nil, &String.to_integer/1)
    |> Map.update("X-RateLimit-Reset", nil, &String.to_integer(&1) * 1000)
  end
end
