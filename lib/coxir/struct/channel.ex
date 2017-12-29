defmodule Coxir.Struct.Channel do
  use Coxir.Struct

  alias Coxir.Struct.{User, Member, Overwrite, Message}

  def pretty(struct) do
    struct
    |> replace(:owner_id, &User.get/1)
  end

  def send_message(term, content, tts \\ false)
  def send_message(%{id: id}, content, tts),
    do: send_message(id, content, tts)

  def send_message(channel, content, tts) do
    body = case content do
      [file: file, name: name] ->
        {:multipart,
          [{:file, file}, {:content, name}]
        }
      [embed: embed] ->
        %{embed: embed}
      content ->
        %{content: content, tts: tts}
    end
    headers = case body do
      {:multipart, _list} ->
        [{"Content-Type", "multipart/form-data"}]
      _ ->
        []
    end
    API.request(:post, "channels/#{channel}/messages", body, headers)
    |> Message.pretty
  end

  def get_message(%{id: id}, message),
    do: get_message(id, message)

  def get_message(channel, message) do
    Message.get(message)
    |> case do
      nil ->
        API.request(:get, "channels/#{channel}/messages/#{message}")
        |> Message.pretty
      message -> message
    end
  end

  def history(term, query \\ [])
  def history(%{id: id}, query),
    do: history(id, query)

  def history(channel, query) do
    API.request(:get, "channels/#{channel}/messages", "", params: query)
    |> case do
      list when is_list(list) ->
        for message <- list do
          Message.pretty(message)
        end
      error -> error
    end
  end

  def get_pinned_messages(%{id: id}),
    do: get_pinned_messages(id)

  def get_pinned_messages(channel) do
    API.request(:get, "channels/#{channel}/pins")
    |> case do
      list when is_list(list) ->
        for message <- list do
          Message.pretty(message)
        end
      error -> error
    end
  end

  def bulk_delete_messages(%{id: id}, messages),
    do: bulk_delete_messages(id, messages)

  def bulk_delete_messages(channel, messages) do
    API.request(:post, "channels/#{channel}/messages/bulk-delete", messages)
  end

  def edit(%{id: id}, params),
    do: edit(id, params)

  def edit(channel, params) do
    API.request(:patch, "channels/#{channel}", params)
    |> pretty
  end

  def delete(%{id: id}),
    do: delete(id)

  def delete(channel) do
    API.request(:delete, "channels/#{channel}")
  end

  def create_permission(%{id: id}, overwrite, params),
    do: create_permission(id, overwrite, params)

  def create_permission(channel, overwrite, params),
    do: Overwrite.edit(channel, overwrite, params)

  def create_invite(term, params \\ %{})
  def create_invite(%{id: id}, params),
    do: create_invite(id, params)

  def create_invite(channel, params) do
    API.request(:post, "channels/#{channel}/invites", params)
  end

  def get_invites(%{id: id}),
    do: get_invites(id)

  def get_invites(channel) do
    API.request(:get, "channels/#{channel}/invites")
  end

  def create_webhook(%{id: id}, params),
    do: create_webhook(id, params)

  def create_webhook(channel, params) do
    API.request(:post, "channels/#{channel}/webhooks", params)
  end

  def get_webhooks(%{id: id}),
    do: get_webhooks(id)

  def get_webhooks(channel) do
    API.request(:get, "channels/#{channel}/webhooks")
  end

  def get_voice_members(%{id: id}),
    do: get_voice_members(id)

  def get_voice_members(channel) do
    pattern = %{voice_id: channel}
    User.select(pattern)
    |> case do
      [] -> Member.select(pattern)
      list -> list
    end
  end
end
