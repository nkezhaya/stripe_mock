import Config

config :stripe_mock, StripeMockWeb.Endpoint, server: false
config :stripe_mock, StripeMock.Repo, pool: Ecto.Adapters.SQL.Sandbox
config :logger, level: :warn

config :stripe_mock, StripeMock.Database, enabled: false

config :stripe_mock, StripeMock.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "stripe_mock_test",
  hostname: System.get_env("POSTGRES_HOST", "localhost"),
  port: System.get_env("POSTGRES_PORT", "5432"),
  username: "postgres",
  password: "postgres",
  pool: Ecto.Adapters.SQL.Sandbox
