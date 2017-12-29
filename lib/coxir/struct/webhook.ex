defmodule Coxir.Struct.Webhook do
  use Coxir.Struct

  def get(webhook) do
    API.request(:get, "webhooks/#{webhook}")
    |> pretty
  end

  def get_with_token(webhook, token) do
    API.request(:get, "webhooks/#{webhook}/#{token}")
    |> pretty
  end

  def edit(webhook, params) do
    API.request(:patch, "webhooks/#{webhook}", params)
    |> pretty
  end

  def edit_with_token(webhook, token, params) do
    API.request(:patch, "webhooks/#{webhook}/#{token}", params)
    |> pretty
  end

  def delete(webhook) do
    API.request(:delete, "webhooks/#{webhook}")
  end

  def delete_with_token(webhook, token) do
    API.request(:delete, "webhooks/#{webhook}/#{token}")
  end

  def execute(webhook, token, params, wait \\ false) do
    API.request(:post, "webhooks/#{webhook}/#{token}", params, params: [wait: wait])
  end

  def execute_slack(webhook, token, params, wait \\ false) do
    API.request(:post, "webhooks/#{webhook}/#{token}/slack", params, params: [wait: wait])
  end

  def execute_github(webhook, token, params, wait \\ false) do
    API.request(:post, "webhooks/#{webhook}/#{token}/github", params, params: [wait: wait])
  end
end
