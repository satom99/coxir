# coxir

[![License](https://img.shields.io/github/license/satom99/coxir.svg)](https://github.com/satom99/coxir/blob/master/LICENSE)
[![Validation](https://github.com/satom99/coxir2/actions/workflows/validation.yml/badge.svg)](https://github.com/satom99/coxir2/actions/workflows/validation.yml)
[![Documentation](https://github.com/satom99/coxir2/actions/workflows/documentation.yml/badge.svg)](https://github.com/satom99/coxir2/actions/workflows/documentation.yml)

A modern high-level Elixir wrapper for [Discord](https://discord.com).

Refer to the [documentation](https://satom99.github.io/coxir2) for more information.

### Installation

Add coxir as a dependency to your `mix.exs` file:

```elixir
defp deps do
  [{:coxir, "~> 0.1.0"}]
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
iex(1)> Example.Bot.start_link
{:ok, #PID<0.301.0>}
```

For a complete and working example have a look on the [`example`](https://github.com/satom99/coxir2/tree/master/example) app.

### More

For more information check out the [documentation](https://satom99.github.io/coxir2).
