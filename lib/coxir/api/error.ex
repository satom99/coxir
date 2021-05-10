defmodule Coxir.API.Error do
  @moduledoc """
  Work in progress.
  """
  alias __MODULE__

  @type t :: %Error{}

  defexception [
    :status,
    :code,
    :message
  ]

  def cast(status, %{"code" => code, "message" => message}) do
    %Error{status: status, code: code, message: message}
  end
end
