defmodule Coxir.Member do
  @moduledoc """
  Work in progress.
  """
  use Coxir.Model

  @primary_key false

  embedded_schema do
    field(:nick, :string)
    field(:roles, {:array, Snowflake})
    field(:joined_at, :utc_datetime)
    field(:premium_since, :utc_datetime)
    field(:deaf, :boolean)
    field(:mute, :boolean)
    field(:pending, :boolean)
    field(:permissions, :integer)

    belongs_to(:user, User, primary_key: true)
    belongs_to(:guild, Guild, primary_key: true)
  end

  def preload(%Member{guild_id: guild_id, roles: roles} = member, :roles, options) do
    roles = Enum.map(roles, &Role.get({&1, guild_id}, options))
    %{member | roles: roles}
  end

  def preload(member, association, options) do
    super(member, association, options)
  end
end
