defmodule Coxir.Voice.Instance do
  @moduledoc """
  Work in progress.
  """
  use Supervisor

  import Supervisor, only: [start_child: 2]

  alias Coxir.Voice.{Audio, Manager, Session}
  alias __MODULE__

  defstruct [
    :guild_id,
    :channel_id
  ]

  def start_session(instance, options) do
    spec = {Session, options}
    start_child(instance, spec)
  end

  def start_link(state) do
    Supervisor.start_link(__MODULE__, state)
  end

  def init(%Instance{guild_id: guild_id, channel_id: channel_id}) do
    udp_socket = Audio.get_udp_socket()

    manager_options = %Manager{
      instance: self(),
      udp_socket: udp_socket,
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
