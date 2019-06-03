use Mix.Config

config :stripe_mock, StripeMockWeb.Endpoint,
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
