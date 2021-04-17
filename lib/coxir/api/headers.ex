defmodule Coxir.API.Headers do
  @moduledoc """
  Work in progress.
  """
  @behaviour Tesla.Middleware

  import Coxir.API.Helper

  alias Tesla.Middleware.Headers

  @project Coxir.MixProject.project()
  @website @project[:source_url]
  @version @project[:version]
  @library @project[:name]

  @agent "#{@library} (#{@website}, #{@version})"

  def call(request, next, _options) do
    token = get_token(request)

    headers = [
      {"User-Agent", @agent},
      {"Authorization", "Bot " <> token}
    ]

    Headers.call(request, next, headers)
  end
end
