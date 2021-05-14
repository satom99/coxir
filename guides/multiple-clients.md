# Multiple clients

This guide explains how multiple clients can be run at once.

### Configuration

As shown in the Configuration guide, each client's `token` must be configured per-gateway.

### Multiple gateways

First of all, let us define two separate modules using the `Coxir.Gateway` module as follows:

```elixir
defmodule Example.Adam do
  use Coxir.Gateway
  
  def handle_event(_event) do
    :noop
  end
end

defmodule Example.Eva do
  use Coxir.Gateway
  
  def handle_event(_event) do
    :noop
  end
end
```

For which we can then, as mentioned, configure their `token` separately the following way:

```elixir
config :coxir, Example.Adam, token: ""

config :coxir, Example.Eva, token: ""
```

Then as mentioned in the Configuration guide, when calling functions we must pass the gateway along:

```elixir
defmodule Example.Adam do
  use Coxir.Gateway
  
  alias Coxir.Message
  alias __MODULE__

  def handle_event({:MESSAGE_CREATE, %Message{content: "!hello"} = message}) do
    Message.reply(message, content: "Hello this is Adam!", as: Adam)
  end
  
  def handle_event(_event) do
    :noop
  end
end

defmodule Example.Eva do
  use Coxir.Gateway
  
  alias Coxir.Message
  alias __MODULE__

  def handle_event({:MESSAGE_CREATE, %Message{content: "!hello"} = message}) do
    Message.reply(message, content: "Hello this is Eva!", as: Eva)
  end
  
  def handle_event(_event) do
    :noop
  end
end
```

In which case the resulting behaviour will be as expected from two separate clients.
