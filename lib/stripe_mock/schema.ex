defmodule StripeMock.Schema do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset, warn: false
      import Ecto.Query
      import unquote(__MODULE__)
      alias StripeMock.{API, Repo}

      Module.put_attribute(__MODULE__, :primary_key, {:id, :binary_id, autogenerate: true})
      Module.put_attribute(__MODULE__, :foreign_key_type, :binary_id)
      Module.put_attribute(__MODULE__, :timestamps_opts, inserted_at: :created, updated_at: false)
    end
  end

  import Ecto.Changeset

  def put_common_fields(changeset) do
    case get_field(changeset, :metadata) do
      nil -> put_change(changeset, :metadata, %{})
      _ -> changeset
    end
  end
end
