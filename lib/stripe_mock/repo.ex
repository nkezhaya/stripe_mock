defmodule StripeMock.Repo do
  use Ecto.Repo, otp_app: :stripe_mock, adapter: Ecto.Adapters.Postgres
  import Ecto.Changeset
  alias StripeMock.Database

  def init(_type, config) do
    {:ok, Keyword.merge(config, Database.ecto_config())}
  end

  def fetch(schema, id) do
    case get(schema, id) do
      nil -> {:error, :not_found}
      object -> {:ok, object}
    end
  end

  defoverridable delete: 1, delete: 2

  def delete(struct) do
    struct
    |> change(%{deleted: true})
    |> update()
  end
end
