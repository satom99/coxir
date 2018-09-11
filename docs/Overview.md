# Overview

coxir is an Elixir wrapper for Discord based on
[nostrum](https://github.com/kraigie/nostrum) and
[alchemy](https://github.com/cronokirby/alchemy).

### Structure

coxir is planned out to be simple and intuitive
both on its internals and when it comes to user
interaction. As such, its structure is rather
straightforward and compact, schemed across multiple
modules as follows.

- [API](./Coxir.API.html) - allows for a direct
interaction with Discord's API whilst keeping track
of all the ratelimits.

- [Gateway](./Coxir.Gateway.html) - supervises all
the gateway workers and includes a few methods to
communicate with.

- Structures - provide specific API calls depending
on the type of the represented Discord object.

- [Voice](./Coxir.Voice.html) - responsible for
handling and supervising all the audio logic
behind voice channels.

Behind the scenes, upon application start, per-shard
gateway workers are started. These are in charge of
receiving data from Discord and piping it through a
GenStage - which consists of two stages: a caching
stage carried out by _Middle_ processes and a consuming
stage. The latter being left in charge of the user.

### Usage

Currently there is no package published on Hex and
instead one must include coxir as follows.

```elixir
defp deps do
  [{:coxir, git: "https://github.com/satom99/coxir.git"}]
end
```

Once installed, coxir must be configured as follows.
The snippet must be added into `config/config.exs`.

```elixir
config :coxir,
  token: "",
  shards: 1, # optional
  ffmpeg: "" # optional
```

Where `token` should be your bot's token and `shards`
the number of shards your bot is to be run at. If this
latter param is not set, it will default to the value
provided by Discord.

Once these steps are completed, one may configure their
application to start a consumer automatically. Usually
this would be done by specifying a module as an application
[callback](https://hexdocs.pm/elixir/Application.html#module-application-module-callback)
which starts a `Supervisor`.

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

Consuming events from the GenStage is now the last
requirement, and may be done easily as follows.

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

Note that when *using* `Coxir` aliases to all the
structures and other crucial modules are included.

One may as well define their own
[Consumer](https://github.com/satom99/coxir/blob/master/lib/coxir/stage/consumer.ex)
and manually subscribe to the processes
returned by `Stage.middles()` - which effectively are
the last stage and responsible for caching data internally.
