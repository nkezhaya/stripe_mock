defmodule StripeMock.API.Customer do
  use StripeMock.Schema

  schema "customers" do
    field :currency, :string, default: "usd"
    field :deleted, :boolean, default: false
    field :email, :string
    field :name, :string
    field :phone, :string

    common_fields()
    timestamps()
  end

  @doc false
  def changeset(customer, attrs) do
    customer
    |> cast(attrs, [:created, :currency, :description, :email, :name, :phone])
    |> validate_email()
    |> put_common_fields()
  end

  defp validate_email(changeset) do
    case get_field(changeset, :email) do
      nil -> changeset
      _ -> validate_format(changeset, :email, ~r/.+@.+\..+/i)
    end
  end
end
