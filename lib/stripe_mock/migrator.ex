defmodule StripeMock.Migrator do
  use GenServer

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  def done? do
    GenServer.call(__MODULE__, :done?)
  end

  @impl true
  def init(_arg) do
    migrate()

    {:ok, nil}
  end

  @impl true
  def handle_call(:done?, _from, state) do
    {:reply, true, state}
  end

  @start_apps [
    :crypto,
    :ssl,
    :postgrex,
    :ecto,
    :ecto_sql
  ]

  @repos [StripeMock.Repo]

  def migrate(_argv \\ nil) do
    # Start apps necessary for executing migrations
    IO.puts("Starting dependencies")
    Enum.each(@start_apps, &Application.ensure_all_started/1)

    Application.load(:basic_space)

    # Start the Repo(s) for app
    # Switch pool_size to 2 for ecto > 3.0
    IO.puts("Starting repos")
    Enum.each(@repos, & &1.start_link(pool_size: 2))

    # Run migrations
    Enum.each(@repos, &run_migrations_for/1)

    # Done
    IO.puts("Success!")
  end

  defp run_migrations_for(repo) do
    app = Keyword.get(repo.config, :otp_app)
    migrations_path = priv_path_for(repo, "migrations")
    IO.puts("Running migrations for #{app}, from #{migrations_path}")
    Ecto.Migrator.run(repo, migrations_path, :up, all: true)
  end

  defp priv_path_for(repo, filename) do
    app = Keyword.get(repo.config, :otp_app)

    repo_underscore =
      repo
      |> Module.split()
      |> List.last()
      |> Macro.underscore()

    priv_dir = "#{:code.priv_dir(app)}"

    Path.join([priv_dir, repo_underscore, filename])
  end
end
