defmodule Coxir.User do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model

  alias Coxir.Token

  @type t :: %User{}

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

  @spec get_me(Loader.options()) :: Model.instance() | Error.t()
  def get_me(options \\ []) do
    options
    |> Token.from_options!()
    |> Token.get_user_id()
    |> get(options)
  end

  @spec create_dm(t, Loader.options()) :: Loader.result()
  def create_dm(%User{id: id}, options \\ []) do
    params = %{recipient_id: id}
    Channel.create(params, options)
  end
end
