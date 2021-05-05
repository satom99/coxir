defmodule Coxir.Voice.Instance do
  @moduledoc """
  Work in progress.
  """
  use Supervisor

  alias Coxir.Voice.{Audio, Manager, Session}

  defstruct [
    :user_id,
    :guild_id,
    :instance,
    :manager,
    :udp_socket,
    :channel_id,
    :session_id,
    :endpoint_host,
    :endpoint_port,
    :token,
    :session,
    :remote_ip,
    :remote_port,
    :ssrc,
    :secret_key,
    # Session-specific
    :gun_pid,
    :stream_ref,
    :heartbeat_ref,
    :heartbeat_nonce,
    :heartbeat_ack
  ]

  def stop_session(instance) do
    Supervisor.terminate_child(instance, :session)
    Supervisor.delete_child(instance, :session)
  end

  def start_session(instance, state) do
    session_spec = generate_session_spec(state)
    Supervisor.start_child(instance, session_spec)
  end

  def get_manager(instance) do
    children = Supervisor.which_children(instance)

    Enum.find_value(
      children,
      fn {id, pid, _type, _modules} ->
        if id == :manager, do: pid
      end
    )
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

  defp generate_session_spec(state) do
    spec = Session.child_spec(state)
    %{spec | id: :session}
  end

  defp generate_manager_spec(state) do
    udp_socket = Audio.get_udp_socket()

    state = %{state | instance: self(), udp_socket: udp_socket}

    spec = Manager.child_spec(state)

    %{spec | id: :manager}
  end
end
