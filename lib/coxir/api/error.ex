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

  def cast(status, _term) do
    %Error{status: status}
  end

  def message(%Error{status: status, code: nil}) do
    reason = :httpd_util.reason_phrase(status)
    "(#{status}) #{reason}"
  end

  def message(%Error{status: status, code: code, message: message}) do
    "(#{status}) #{code} - #{message}"
  end
end
