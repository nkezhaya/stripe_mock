defmodule StripeMockWeb.Plug.EnsureMigratorFinished do
  def init(arg) do
    arg
  end

  def call(conn, _arg) do
    true = StripeMock.Migrator.done?()

    conn
  end
end
