options = [
  timeout: :infinity
]

handler = fn index ->
  Coxir.API.request(
    method: :post,
    url: "channels/831655754222141450/messages",
    body: %{content: "#{index}"},
    opts: [token: "MTYzODAxMjk0MDAyMzIzNDU4.Vvh11w.415BN48HUxWIlUuRN2JczW_ixpo"])
end

1..15 \
|> Task.async_stream(handler, options) \
|> Stream.map(&elem(&1, 1)) \
|> Stream.map(&elem(&1, 1)) \
|> Stream.filter(& &1.status == 429) \
|> Enum.to_list() \
|> length

Coxir.API.request(
    method: :post,
    url: "channels/831655754222141450/messages",
    body: %{content: "test"},
    opts: [token: "MTYzODAxMjk0MDAyMzIzNDU4.Vvh11w.415BN48HUxWIlUuRN2JczW_ixpo"])

:ets.tab2list(Coxir.Limiter.Default)
