defmodule Coxir.API.Base do
  @moduledoc false

  use HTTPoison.Base

  @project Coxir.Mixfile.project()
  @website @project[:source_url]
  @version @project[:version]
  @library @project[:name]

  def process_url(path) do
    "https://discordapp.com/api/" <> path
  end

  def process_request_body(""), do: ""
  def process_request_body({:multipart, _list} = body), do: body
  def process_request_body(body) do
    Jason.encode!(body)
  end

  def process_request_headers(headers) do
    token = Application.get_env(:coxir, :token)
    [
      {"User-Agent", "#{@library} (#{@website}, #{@version})"},
      {"Authorization", "Bot " <> token},
      {"Content-Type", "application/json"}
      | headers
    ]
  end
end
