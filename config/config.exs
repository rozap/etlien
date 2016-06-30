# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :etlien, Etlien.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "d8gmCZg0oi3x5mnVHN2BCiSfCDaElvd1SZMBIoBX3a6J+GMvJ6iMKo62e1+OggqE",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: Etlien.PubSub,
           adapter: Phoenix.PubSub.PG2]


config :etlien, ecto_repos: [Etlien.Repo]
# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false

config :etlien, :nice,
  default_timeout: 500

config :etlien, :persist,
  water_mark: 8,
  count: 1,
  max_attempt_timeout: 200,
  path: "/tmp/etlien"

config :etlien, :broker,
  water_mark: 16

config :etlien, :set,
  water_mark: 8,
  count: 1,
  max_attempt_timeout: 200

config :etlien, :applicator,
  store_at_ms: 100

config :etlien, :api,
  chunk_size_bytes: 1024