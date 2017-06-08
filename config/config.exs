# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :shallowblue,
  ecto_repos: [Shallowblue.Repo]

# Configures the endpoint
config :shallowblue, Shallowblue.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "NRJ+BnT6CUZkLRn+bxJ1f7XU8t1x6pnVwuFT3S7YhfO1e67t4YLQ6bHTP+k2+7FB",
  render_errors: [view: Shallowblue.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Shallowblue.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

config :guardian, Guardian,
  allowed_algos: ["HS512"], # optional
  verify_module: Guardian.JWT,  # optional
  issuer: "Shallowblue",
  ttl: { 30, :days },
  allowed_drift: 2000,
  verify_issuer: true, # optional
  secret_key: "dt0GQRyMNbWFORV3CsAakKljmcHHOLZn3JoIGQJsdeqXp4TcLTrEplDOp9/Xvaz7",
  serializer: Shallowblue.GuardianSerializer
