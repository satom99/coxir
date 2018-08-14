defmodule Reply.Consumer do
  use Coxir

  def handle_event({:MESSAGE_CREATE, message}, state) do
    case message.content do
      "!hello" ->
          Message.reply(message, "Hello #{message.author.username}, how are you?")
      _ ->
        :ignore
      end
      {:ok, state}
  end

  def handle_event(_event, state) do
    {:ok, state}
  end
end
