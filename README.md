# coxir

[![License](https://img.shields.io/github/license/satom99/coxir.svg)](https://github.com/satom99/coxir/blob/master/LICENSE)
[![Build Status](https://travis-ci.org/satom99/coxir.svg?branch=master)](https://travis-ci.org/satom99/coxir)
[![Join Discord](https://img.shields.io/badge/discord-join-7289DA.svg)](https://discord.gg/6JrqNEX)
[![Donate](https://img.shields.io/badge/donate-PayPal-yellow.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=JKKHNZF6RAKDA&item_name=coxir&currency_code=USD)

An Elixir wrapper for Discord.
Based on [nostrum](https://github.com/Kraigie/nostrum)
and [alchemy](https://github.com/cronokirby/alchemy).

Please refer to the [documentation](https://satom99.github.io/coxir)
for more information on the library.

### Installation

One should simply include coxir as a dependency as follows.

```elixir
defp deps do
  [{:coxir, git: "https://github.com/satom99/coxir.git"}]
end
```

### Getting started

Before setting up a consumer, coxir must be
[configured](http://elixir-recipes.github.io/mix/configuration/)
as follows.

```elixir
config :coxir,
  token: "",
  shards: 1, # optional
  ffmpeg: "" # optional
```

In order to process incoming events, a consumer should be set up as follows.

```elixir
defmodule Consumer do
  use Coxir

  def handle_event({:MESSAGE_CREATE, message}, state) do
    case message.content do
      "ping!" ->
        Message.reply(message, "pong!")
      _ ->
        :ignore
    end

    {:ok, state}
  end

  def handle_event(_event, state) do
    {:ok, state}
  end
end
```

Once all the above is done, the application may be configured
in any desired fashion so that a consumer process is started.

```elixir
defmodule Example do
  use Application
  use Supervisor

  def start(_type, _args) do
    children = [
      worker(Consumer, [])
    ]
    options = [
      strategy: :one_for_one,
      name: __MODULE__
    ]
    Supervisor.start_link(children, options)
  end
end
```

A common approach to which would be the above,
of course after configuring the module as a
[callback](https://hexdocs.pm/elixir/Application.html#module-application-module-callback).
