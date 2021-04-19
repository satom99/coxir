defmodule Coxir.Gateway.Intents do
  @moduledoc """
  Work in progress.
  """
  import Bitwise

  @intents [
    guilds: 1 <<< 0,
    guild_members: 1 <<< 1,
    guild_bans: 1 <<< 2,
    guild_emojis: 1 <<< 3,
    guild_integrations: 1 <<< 4,
    guild_webhooks: 1 <<< 5,
    guild_invites: 1 <<< 6,
    guild_voice_states: 1 <<< 7,
    guild_presences: 1 <<< 8,
    guild_messages: 1 <<< 9,
    guild_message_reactions: 1 <<< 10,
    guild_message_typing: 1 <<< 11,
    direct_messages: 1 <<< 12,
    direct_message_reactions: 1 <<< 13,
    direct_message_typing: 1 <<< 14
  ]

  @names @intents
         |> Keyword.keys()
         |> Enum.reduce(fn name, type ->
           {:|, [], [name, type]}
         end)

  @type intent :: unquote(@names)

  def get_value(intents) do
    Enum.reduce(
      intents,
      0,
      fn intent, value ->
        Keyword.fetch!(@intents, intent) ||| value
      end
    )
  end
end
