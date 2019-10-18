defmodule StripeMock.Repo do
  use Ecto.Repo, otp_app: :stripe_mock, adapter: Ecto.Adapters.Postgres
  import Ecto.Changeset
  alias StripeMock.Database

  def init(_type, config) do
    {:ok, Keyword.merge(config, Database.ecto_config())}
  end

  def fetch(schema, id) do
    if valid_uuid?(id) do
      get(schema, id)
    else
      get_by(schema, stripe_id: id)
    end
    |> case do
      nil -> {:error, :not_found}
      object -> {:ok, object}
    end
  end

  defp valid_uuid?(id) do
    case Ecto.UUID.cast(id) do
      {:ok, _} -> true
      _ -> false
    end
  end

  defoverridable delete: 1, delete: 2

  def delete(struct) do
    struct
    |> change(%{deleted: true})
    |> update()
  end

  if Mix.env() == :test do
    defp set_client_ip(changeset) do
      if Map.has_key?(changeset.data, :client_ip) and is_nil(get_field(changeset, :client_ip)) do
        put_change(changeset, :client_ip, "0.0.0.0")
      else
        changeset
      end
    end
  else
    defp set_client_ip(changeset) do
      changeset
    end
  end
end
