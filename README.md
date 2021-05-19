# coxir

[![License](https://img.shields.io/github/license/satom99/coxir.svg)](https://github.com/satom99/coxir/blob/main/LICENSE)
[![Validation](https://github.com/satom99/coxir/actions/workflows/validation.yml/badge.svg)](https://github.com/satom99/coxir/actions/workflows/validation.yml)
[![Documentation](https://github.com/satom99/coxir/actions/workflows/documentation.yml/badge.svg)](https://github.com/satom99/coxir/actions/workflows/documentation.yml)
[![Join Discord](https://img.shields.io/badge/Discord-join-7289DA.svg)](https://discord.gg/6JrqNEX)

A modern high-level Elixir wrapper for [Discord](https://discord.com).

Refer to the [documentation](https://satom.me/coxir) for more information.

### Features

- Support for running multiple bots in a same application
- Configurable adapters that change how the library behaves:
  - **Limiter:** handles how rate limit buckets are stored
  - **Storage:** handles how entities are cached
  - **Sharder:** handles how shards are started
  - **Player:** handles the audio sent through voice
- Easy-to-use syntax for interacting with Discord entities

### Installation

Add coxir as a dependency to your `mix.exs` file:

```elixir
defp deps do
  [{:coxir, git: "https://github.com/satom99/coxir.git"}]
end
```

### Quickstart

Before consuming events, coxir must be configured:

```elixir
config :coxir,
  token: "",
  intents: :non_privileged # optional
```

Then a simple consumer can be set up as follows:

```elixir
defmodule Example.Bot do
  use Coxir.Gateway
  
  alias Coxir.{User, Message}

  def handle_event({:MESSAGE_CREATE, %Message{content: "!hello"} = message}) do
    %Message{author: author} = Message.preload(message, :author)

    %User{username: username, discriminator: discriminator} = author

    Message.reply(message, content: "Hello #{username}##{discriminator}!")
  end
  
  def handle_event(_event) do
    :noop
  end
end
```

Which can then be added to a Supervisor, or started directly:

```elixir
iex(1)> Example.Bot.start_link()
{:ok, #PID<0.301.0>}
```

For a complete and working example check out the [`example`](https://github.com/satom99/coxir/tree/main/example) app.

### More

For more information check out the [documentation guides](https://satom.me/coxir).
