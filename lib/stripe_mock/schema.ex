defmodule StripeMock.Schema do
  import Ecto.Changeset
  alias StripeMock.ID

  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset, warn: false
      import Ecto.Query
      import unquote(__MODULE__)
      alias StripeMock.{API, Repo}

      Module.put_attribute(__MODULE__, :primary_key, {:id, :binary_id, autogenerate: false})
      Module.put_attribute(__MODULE__, :foreign_key_type, :binary_id)
      Module.put_attribute(__MODULE__, :timestamps_opts, inserted_at: :created, updated_at: false)
    end
  end

  defmacro common_fields() do
    quote do
      field :stripe_id, :string
      field :description, :string
      field :metadata, :map, default: %{}
    end
  end

  def put_common_fields(changeset) do
    changeset
    |> validate_required(required_fields(changeset))
    |> put_ids()
  end

  defp required_fields(changeset) do
    Enum.filter([:metadata], &Map.has_key?(changeset.data, &1))
  end

  defp put_ids(changeset) do
    case get_field(changeset, :id) do
      nil -> do_put_stripe_id(changeset)
      _ -> changeset
    end
  end

  defp do_put_stripe_id(changeset) do
    uuid = Ecto.UUID.generate()
    prefix = ID.prefix(changeset.data)
    stripe_id = prefix <> "_" <> StripeMock.ID.from_uuid(uuid)

    change(changeset, %{id: uuid, stripe_id: stripe_id})
  end
end
