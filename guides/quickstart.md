# Quickstart

This guide offers a quick and simple example to get started with the library.

### Installation

Add coxir as a dependency to your `mix.exs` file:

```elixir
defp deps do
  [{:coxir, "~> 2.0.0"}]
end
```

### Consuming events

In order to start consuming events from the Discord gateway, first configure the library:

```elixir
config :coxir,
  token: "",
  intents: :non_privileged
```

And then define a module that will be responsible for handling the incoming events like:

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

Which can then be added to a Supervisor as a child, or started directly from `iex` like:

```elixir
iex(1)> Example.Bot.start_link()
{:ok, #PID<0.301.0>}
```

For a complete and working example it is highly recommended to check out the [`example`](https://github.com/satom99/coxir/tree/main/example) app.
