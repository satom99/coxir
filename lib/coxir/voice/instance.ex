defmodule Coxir.Voice.Instance do
  @moduledoc """
  Work in progress.
  """
  use Supervisor

  alias Coxir.Voice.Manager
  alias __MODULE__

  defstruct [
    :guild_id,
    :channel_id
  ]

  def start_link(state) do
    Supervisor.start_link(__MODULE__, state)
  end

  def init(%Instance{guild_id: guild_id, channel_id: channel_id}) do
    manager_options = %Manager{
      instance: self(),
      guild_id: guild_id,
      channel_id: channel_id
    }

    children = [
      {Manager, manager_options}
    ]

    options = [
      strategy: :rest_for_one
    ]

    Supervisor.init(children, options)
  end
end
