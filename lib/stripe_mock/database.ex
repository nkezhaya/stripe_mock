defmodule StripeMock.Database do
  @moduledoc """
  Start the database and hold the Repo config in its state.
  """

  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, enabled?(), name: __MODULE__)
  end

  def enabled?() do
    Application.get_env(:stripe_mock, __MODULE__, [])
    |> Keyword.get(:enabled, true)
  end

  def ecto_config() do
    GenServer.call(__MODULE__, :config)
  end

  @impl true
  def init(true) do
    {uri, _} = System.cmd("pg_tmp", ["-t", "-w", "180"])

    [[username, host, port, database]] =
      Regex.scan(~r/(\w+)@([\w\d\.]+)\:(\d+)\/(\w+)/i, uri, capture: :all_but_first)

    config = [
      username: username,
      password: "",
      database: database,
      hostname: host,
      port: port,
      pool_size: 2,
      migration_primary_key: [type: :string]
    ]

    {:ok, config}
  end

  def init(false) do
    # Create the permanent database
    config = Application.get_env(:stripe_mock, StripeMock.Repo)

    case Ecto.Adapters.Postgres.storage_up(config) do
      :ok ->
        nil

      {:error, :already_up} ->
        nil

      {:error, term} ->
        raise "The database couldn't be created: #{inspect(term)}"
    end

    {:ok, []}
  end

  @impl true
  def handle_call(:config, _from, state) do
    {:reply, state, state}
  end
end
