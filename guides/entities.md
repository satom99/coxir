# Entities

This guide shows the correct use of the functions of an entity.

### Errors

Suppose we want to get a specific Discord channel. We would do as follows:

```elixir
Coxir.Channel.get(432535429162729494)
```

Which would return a `t:Coxir.Channel.t/0` struct if everything goes right. However:

```elixir
Coxir.Channel.get(0)
```

Here we are trying to get a channel with an invalid id. This is obviously going to fail.

In this case we instead get a `t:Coxir.API.Error.t/0` struct describing what went wrong.

Now imagine we try to get a channel we don't have permissions to view. We get another error.

So when getting entities, always make sure the returned struct is not that of an error.

### Bang functions

If you however want to keep it simple, the bang equivalent function can be used:

```elixir
Coxir.Channel.get!(0)
```

Which will just raise if there is an error. These should be used with caution, however.

### Preloading

Suppose we want to get the guild a specific channel belongs to. We can do as follows:

```elixir
channel = Coxir.Channel.preload!(channel, :guild)
```

Which will set the `:guild` field of the given `channel` to the associated `t:Coxir.Guild.t/0`.

If the given channel has no associated guild, the field will simply be set to `nil`.

If there is an error getting the associated guild, the field will be set to the error's struct.

Note though that the example uses `preload!/2` which means that it will raise in case of error.
