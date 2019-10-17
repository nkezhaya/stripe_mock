defmodule StripeMock.Repo do
  use Ecto.Repo, otp_app: :stripe_mock, adapter: Ecto.Adapters.Postgres
  import Ecto.Changeset
  alias StripeMock.API

  @impl true
  def init(_type, config) do
    {uri, _} = System.cmd("pg_tmp", ["-t"])

    [[username, host, port, database]] =
      Regex.scan(~r/(\w+)@([\w\d\.]+)\:(\d+)\/(\w+)/i, uri, capture: :all_but_first)

    config =
      Keyword.merge(config,
        username: username,
        password: "",
        database: database,
        hostname: host,
        port: port,
        pool_size: 2,
        migration_primary_key: [name: :id, type: :binary_id]
      )

    {:ok, config}
  end

  def fetch(schema, id) do
    with true <- valid_id?(id),
         %{} = object <- get(schema, id) do
      {:ok, object}
    else
      _ -> {:error, :not_found}
    end
  end

  defp valid_id?(id) do
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

  defp generate_id(schema) do
    prefix(schema) <> "_" <> StripeMock.ID.generate()
  end

  def type(%{} = map), do: type(map.__struct__)
  def type(API.Card), do: :card
  def type(API.Charge), do: :charge
  def type(API.Customer), do: :customer
  def type(API.PaymentIntent), do: :payment_intent
  def type(API.Refund), do: :refund
  def type(API.Token), do: :token

  def prefix(%API.Card{}), do: "card"
  def prefix(%API.Charge{}), do: "ch"
  def prefix(%API.Customer{}), do: "cus"
  def prefix(%API.PaymentIntent{}), do: "pi"
  def prefix(%API.Refund{}), do: "re"
  def prefix(%API.Token{}), do: "tok"
end
