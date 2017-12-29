defmodule Coxir.Struct.User do
  use Coxir.Struct

  alias Coxir.Struct.{Channel}

  def pretty(struct) do
    struct
    |> replace(:voice_id, &Channel.get/1)
  end

  def get(user \\ "@me")
  def get(nil), do: nil
  def get(%{id: id}),
    do: get(id)

  def get(user) do
    super(user)
    |> case do
      nil ->
        API.request(:get, "users/#{user}")
        |> pretty
      user -> user
    end
  end

  def edit(params) do
    API.request(:patch, "users/@me", params)
  end

  def get_connections do
    API.request(:get, "users/@me/connections")
  end

  def get_guilds(query \\ []) do
    API.request(:get, "users/@me/guilds", "", params: query)
  end

  def create_dm(%{id: id}),
    do: create_dm(id)

  def create_dm(recipient) do
    API.request(:post, "users/@me/channels", %{recipient_id: recipient})
    |> Channel.pretty
  end

  def create_group(params) do
    API.request(:post, "users/@me/channels", params)
    |> Channel.pretty
  end

  def get_dms do
    API.request(:get, "users/@me/channels")
    |> case do
      list when is_list(list) ->
        for channel <- list do
          Channel.pretty(channel)
        end
      error -> error
    end
  end
end
