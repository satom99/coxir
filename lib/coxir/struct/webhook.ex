defmodule Coxir.Struct.Webhook do
  @moduledoc """
  Defines methods used to interact with channel webhooks.

  Refer to [this](https://discordapp.com/developers/docs/resources/webhook#webhook-object)
  for a list of fields and a broader documentation.
  """

  use Coxir.Struct

  @doc false
  def select(pattern)

  @doc """
  Fetches a webhook.

  Returns a webhook object upon success
  or a map containing error information.
  """

  def get(webhook) do
    API.request(:get, "webhooks/#{webhook}")
    |> pretty
  end

  @doc """
  Fetches a webhook.

  Refer to [this](https://discordapp.com/developers/docs/resources/webhook#get-webhook-with-token)
  for more information.
  """
  @spec get_with_token(String.t, String.t) :: map

  def get_with_token(webhook, token) do
    API.request(:get, "webhooks/#{webhook}/#{token}")
    |> pretty
  end

  @doc """
  Modifies a given webhook.

  Returns a webhook object upon success
  or a map containing error information.

  #### Params
  Must be an enumerable with the fields listed below.
  - `name` - the default name of the webhook
  - `avatar` - image for the default webhook avatar
  - `channel_id` - the new channel id to be moved to

  Refer to [this](https://discordapp.com/developers/docs/resources/webhook#modify-webhook)
  for a broader explanation on the fields and their defaults.
  """
  @spec edit(String.t, Enum.t) :: map

  def edit(webhook, params) do
    API.request(:patch, "webhooks/#{webhook}", params)
    |> pretty
  end

  @doc """
  Modifies a given webhook.

  Refer to [this](https://discordapp.com/developers/docs/resources/webhook#modify-webhook-with-token)
  for more information.
  """
  @spec edit_with_token(String.t, String.t, Enum.t) :: map

  def edit_with_token(webhook, token, params) do
    API.request(:patch, "webhooks/#{webhook}/#{token}", params)
    |> pretty
  end

  @doc """
  Deletes a given webhook.

  Returns the atom `:ok` upon success
  or a map containing error information.
  """
  @spec delete(String.t) :: :ok | map

  def delete(webhook) do
    API.request(:delete, "webhooks/#{webhook}")
  end

  @doc """
  Deletes a given webhook.

  Refer to [this](https://discordapp.com/developers/docs/resources/webhook#delete-webhook-with-token)
  for more information.
  """
  @spec delete_with_token(String.t, String.t) :: :ok | map

  def delete_with_token(webhook, token) do
    API.request(:delete, "webhooks/#{webhook}/#{token}")
  end

  @doc """
  Executes a given webhook.

  Refer to [this](https://discordapp.com/developers/docs/resources/webhook#execute-webhook)
  for more information.
  """
  @spec execute(String.t, String.t, Enum.t, boolean) :: map

  def execute(webhook, token, params, wait \\ false) do
    API.request(:post, "webhooks/#{webhook}/#{token}", params, params: [wait: wait])
  end

  @doc """
  Executes a given *Slack* webhook.

  Refer to [this](https://discordapp.com/developers/docs/resources/webhook#execute-slackcompatible-webhook)
  for more information.
  """
  @spec execute_slack(String.t, String.t, Enum.t, boolean) :: map

  def execute_slack(webhook, token, params, wait \\ false) do
    API.request(:post, "webhooks/#{webhook}/#{token}/slack", params, params: [wait: wait])
  end

  @doc """
  Executes a given *GitHub* webhook.

  Refer to [this](https://discordapp.com/developers/docs/resources/webhook#execute-githubcompatible-webhook)
  for more information.
  """
  @spec execute_github(String.t, String.t, Enum.t, boolean) :: map

  def execute_github(webhook, token, params, wait \\ false) do
    API.request(:post, "webhooks/#{webhook}/#{token}/github", params, params: [wait: wait])
  end
end
