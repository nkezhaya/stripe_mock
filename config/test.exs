use Mix.Config

config :stripe_mock, StripeMockWeb.Endpoint, server: false
config :stripe_mock, StripeMock.Repo, pool: Ecto.Adapters.SQL.Sandbox
config :logger, level: :warn
