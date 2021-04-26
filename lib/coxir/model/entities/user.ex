defmodule Coxir.User do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model

  embedded_schema do
    field(:username, :string)
    field(:discriminator, :string)
    field(:avatar, :string)
    field(:bot, :boolean)
    field(:system, :boolean)
    field(:mfa_enabled, :boolean)
    field(:locale, :string)
    field(:verified, :boolean)
    field(:email, :string)
    field(:flags, :integer)
    field(:premium_type, :integer)
    field(:public_flags, :integer)
  end

  def fetch(id, options) do
    API.get("users/#{id}", options)
  end
end
