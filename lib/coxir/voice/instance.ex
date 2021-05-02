defmodule Coxir.Voice.Instance do
  @moduledoc """
  Work in progress.
  """
  use Supervisor

  alias Coxir.Voice.Session

  def start_link(session_options) do
    Supervisor.start_link(__MODULE__, session_options)
  end

  def init(session_options) do
    children = [
      {Session, session_options}
    ]

    options = [
      strategy: :rest_for_one
    ]

    Supervisor.init(children, options)
  end
end
