defmodule StripeMock do
  @moduledoc """
  StripeMock is a service that duplicates some of the core functionality of the
  Stripe API, without doing enough to receive a cease-and-desist letter from
  Stripe's legal team.

  This has been created for testing purposes only. MY GOD will it speed up your
  test suite.

  First, add the dependency to your `mix.exs`:

      {:stripe_mock, "~> 0.1.0"}

  (or whatever the latest version is; I probably won't be updating this moduledoc.)

  In your app's `config/test.exs` file:

      config :stripity_stripe, :api_base_url, "http://localhost:12111/v1/"
      config :stripe_mock, StripeMockWeb.Endpoint, http: [port: 12111], server: true

  That should get the StripeMock server to start in your test environment.

  No database connection is needed. `StripeMock.Repo` is just a GenServer that
  stores everything in its state. It'd be nice if `ecto_mnesia` was updated for
  Ecto 3, but as of right now this is the next best option.
  """

  @doc """
  Truncates all tables.
  """
  def reset() do
    StripeMock.Repo.query!("""
    TRUNCATE
      cards,
      customers,
      tokens,
      sources,
      payment_methods,
      payment_intents,
      charges,
      refunds
    CASCADE
    """)

    :ok
  end
end
