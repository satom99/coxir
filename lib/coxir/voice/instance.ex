defmodule Coxir.Voice.Instance do
  @moduledoc """
  Work in progress.
  """
  use Supervisor

  import Supervisor, only: [start_child: 2]

  alias Coxir.Voice.{Audio, Manager, Session}

  defstruct [
    :instance,
    :manager,
    :udp_socket,
    :user_id,
    :guild_id,
    :channel_id,
    :session_id,
    :endpoint,
    :token,
    :remote_ip,
    :remote_port,
    :ssrc,
    :secret_key,
    # Session-only
    :gun_pid,
    :stream_ref,
    :heartbeat_ref,
    :heartbeat_nonce,
    :heartbeat_ack
  ]

  def get_manager(instance) do
    children = Supervisor.which_children(instance)

    Enum.find_value(
      children,
      fn {id, pid, _type, _modules} ->
        if id == :manager, do: pid
      end
    )
  end

  def start_session(instance, options) do
    spec = {Session, options}
    start_child(instance, spec)
  end

  def start_link(state) do
    Supervisor.start_link(__MODULE__, state)
  end

  def init(state) do
    children = [
      generate_manager_spec(state)
    ]

    options = [
      strategy: :rest_for_one
    ]

    Supervisor.init(children, options)
  end

  defp generate_manager_spec(state) do
    udp_socket = Audio.get_udp_socket()

    state = %{state | instance: self(), udp_socket: udp_socket}

    manager_spec = Manager.child_spec(state)

    %{manager_spec | id: :manager}
  end
end
