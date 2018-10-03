defmodule Coxir.Struct.Invite do
  @moduledoc """
  Defines methods used to interact with guild invites.

  Refer to [this](https://discordapp.com/developers/docs/resources/invite#invite-object)
  for a list of fields and a broader documentation.
  """
  @type invite :: String.t | map

  use Coxir.Struct

  @doc false
  def select(pattern)

  @doc """
  Fetches an invite.

  Returns an invite object upon success
  or a map containing error information.

  Accepts an optional parameter `with_counts`
  in which the invite struct will contain two
  extra keys, approximate_member_count, the
  number of members in the server, and
  approximate_presence_count which is the number
  of users in the server who are currently online.
  """
  @spec get(invite, boolean()) :: map

  def get(code, with_counts \\ false) do
    API.request(:get, "invites/#{code}?with_counts=#{with_counts}")
  end

  @doc """
  Accepts a given invite.

  Returns an invite object upon success
  or a map containing error information.
  """
  @spec accept(invite) :: map

  def accept(%{code: code}),
    do: accept(code)

  def accept(code) do
    API.request(:post, "invites/#{code}")
  end

  @doc """
  Deletes a given invite.

  Returns an invite object upon success
  or a map containing error information.
  """
  @spec delete(invite) :: map

  def delete(%{code: code}),
    do: delete(code)

  def delete(code) do
    API.request(:delete, "invites/#{code}")
  end
end
