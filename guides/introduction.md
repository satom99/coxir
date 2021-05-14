# Introduction

coxir is a modern high-level Elixir wrapper for [Discord](https://discord.com).

### Features

- Support for running multiple bots in a same application
- Configurable adapters that change how the library behaves:
  - **Limiter:** handles how rate limit buckets are stored
  - **Storage:** handles how entities are cached
  - **Sharder:** handles how shards are started
  - **Player:** handles the audio sent through voice
- Easy-to-use syntax for interacting with Discord entities
