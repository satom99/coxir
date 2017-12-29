defmodule Coxir.Voice.UDP do
  @moduledoc false

  def open(server, port, ssrc) do
    {:ok, server} = server
    |> String.to_charlist
    |> :inet_parse.address

    options = [
      :binary,
      {:active, false},
      {:reuseaddr, true}
    ]
    {:ok, udp} = :gen_udp.open(0, options)

    packet = <<ssrc::size(560)>>
    :gen_udp.send(udp, server, port, packet)

    {:ok, packet} = :gen_udp.recv(udp, 70)

    <<_padding::size(32), ip::bitstring-size(112),
      _null::size(400), port::size(16)>> \
      = packet
      |> Tuple.to_list
      |> List.last

    {udp, server, ip, port}
  end
end
