defmodule StripeMock.API.Customer do
  use StripeMock.Schema

  @primary_key {:id, :binary_id, autogenerate: false}
  schema "customers" do
    field :created, :integer
    field :currency, :string, default: "usd"
    field :deleted, :boolean, default: false
    field :description, :string
    field :email, :string
    field :metadata, StripeMock.Type.Metadata, default: %{}
    field :name, :string
    field :phone, :string
  end

  @doc false
  def changeset(customer, attrs) do
    customer
    |> cast(attrs, [:created, :currency, :description, :email, :name, :phone])
    |> validate_email()
  end

  defp validate_email(changeset) do
    case get_field(changeset, :email) do
      nil -> changeset
      _ -> validate_format(changeset, :email, ~r/.+@.+\..+/i)
    end
  end
end
