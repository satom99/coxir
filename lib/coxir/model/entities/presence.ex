defmodule Coxir.Presence do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model

  @primary_key false

  embedded_schema do
    field(:status, :string)

    field(:member, :any, virtual: true)

    belongs_to(:user, User, primary_key: true)
    belongs_to(:guild, Guild, primary_key: true)
  end

  def preload(%Presence{member: %Member{}} = presence, :member, options) do
    if options[:force] do
      presence = %{presence | member: nil}
      preload(presence, :member, options)
    else
      presence
    end
  end

  def preload(%Presence{user_id: user_id, guild_id: guild_id} = presence, :member, options) do
    member = Member.get({user_id, guild_id}, options)
    %{presence | member: member}
  end

  def preload(presence, association, options) do
    super(presence, association, options)
  end

  @doc false
  def create(params, options)
end
