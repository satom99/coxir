defmodule Coxir.Struct.Invite do
  use Coxir.Struct

  def get(code) do
    API.request(:get, "invites/#{code}")
  end

  def accept(%{code: code}),
    do: accept(code)

  def accept(code) do
    API.request(:post, "invites/#{code}")
  end

  def delete(%{code: code}),
    do: delete(code)

  def delete(code) do
    API.request(:delete, "invites/#{code}")
  end
end
