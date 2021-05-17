# Configuration

This guide explains the different configuration possibilities the library has.

### Global

The following table shows a complete list of the fields that can be configured globally:

| Field         | Description                                 | Default                        | Global? |
|---------------|---------------------------------------------|--------------------------------|---------|
| `limiter`     | The Limiter adapter coxir should use.       | `Coxir.Limiter.Default`        | ✓       |
| `storage`     | The Storage adapter coxir should use.       | `Coxir.Storage.Default`        | ✓       |
| `storables`   | The list of entities coxir should store.    | All storable entities.         | ✓       |
| `token`       | The default token to be used for API calls. |                                |         |
| `ìntents`     | The default gateway intents value to use.   | `:non_privileged`              |         |
| `shard_count` | The amount of gateway shards to use.        | The value provided by Discord. |         |

Which means that either of these fields can be configured under the `:coxir` application.

### Gateway-specific

Instead of global configuration, fields not marked as **GLOBAL?** can be configured at gateway level like:

```elixir
config :coxir, Example.Bot, token: ""
```

where `Example.Bot` in this example is the name of a module that uses the `Coxir.Gateway` module.

### When a token is not configured globally

If no token is configured globally but configured for a gateway instead, the following is required:

```elixir
Coxir.Channel.get(432535429162729494, as: Example.Bot)
```

where a gateway process must be passed as the `:as` option. Or if there is no available gateway:

```elixir
Coxir.Channel.get(432535429162729494, token: "")
```

Note that this applies to most functions. Be sure to always check out the functions' specification.
