defmodule Coxir.Voice.Audio do
  @moduledoc """
  Work in progress.
  """
  @encryption_mode "xsalsa20_poly1305"

  defstruct [
    :udp_socket,
    :ip,
    :port,
    :ssrc,
    :secret_key
  ]

  def encryption_mode do
    @encryption_mode
  end

  def get_udp_socket do
    options = [
      :binary,
      {:active, false},
      {:reuseaddr, true}
    ]

    {:ok, socket} = :gen_udp.open(0, options)

    socket
  end

  def discover_local(udp_socket, remote_ip, remote_port, ssrc) do
    remote_address = ip_to_address(remote_ip)

    padded_remote_ip = String.pad_trailing(remote_ip, 64, <<0>>)

    request = <<1::16, 70::16, ssrc::32>> <> padded_remote_ip <> <<remote_port::16>>

    :ok = :gen_udp.send(udp_socket, remote_address, remote_port, request)

    {:ok, received} = :gen_udp.recv(udp_socket, 74)

    {^remote_address, ^remote_port, response} = received

    <<2::16, 70::16, ^ssrc::32, local_ip::bitstring-size(512), local_port::16>> = response

    local_ip = String.trim(local_ip, <<0>>)

    {local_ip, local_port}
  end

  defp ip_to_address(ip) do
    {:ok, address} =
      ip
      |> String.to_charlist()
      |> :inet_parse.address()

    address
  end
end
