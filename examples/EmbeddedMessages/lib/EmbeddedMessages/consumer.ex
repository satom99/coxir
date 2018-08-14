defmodule EmbeddedMessages.Consumer do
  use Coxir

  def handle_event({:MESSAGE_CREATE, message}, state) do
    case message.content do
      "!embed" ->
          embed = %{
            title: "I am an embedded message!",
            description: "And it looks really nice.",
            color: 2876827, #Decimal value
            footer: %{
              text: "on Elixir #{System.version()}"
            }
          }
          Message.reply(message, embed: embed)
      _ ->
        :ignore
      end
      {:ok, state}
  end

  def handle_event(_event, state) do
    {:ok, state}
  end
end
