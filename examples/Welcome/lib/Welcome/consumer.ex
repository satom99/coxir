defmodule Welcome.Consumer do
  use Coxir

  def handle_event({:GUILD_MEMBER_ADD, data}, state) do
    data.user.id
    |> User.send_message("hello")
    
    {:ok, state}
  end

  def handle_event(_event, state) do
    {:ok, state}
  end
end
