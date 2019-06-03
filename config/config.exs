# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :stripe_mock, StripeMockWeb.Endpoint,
  url: [host: "localhost"],
  http: [:inet6, port: System.get_env("PORT") || 12111],
  secret_key_base: "ug9ATr9o7f/N2inxnW+SlrNVP7Ok+f9gAP43yHfqqm/bgFZSLeY6vQOY+wp562Iz",
  render_errors: [view: StripeMockWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: StripeMock.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
