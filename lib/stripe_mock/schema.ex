defmodule StripeMock.Schema do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset, warn: false
      alias StripeMock.API
    end
  end
end
