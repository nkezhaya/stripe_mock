defmodule StripeMock.API.Charge do
  use Ecto.Schema
  import Ecto.Changeset

  alias StripeMock.API

  @foreign_key_type :binary_id
  schema "charges" do
    field :amount, :integer
    field :capture, :boolean, default: false
    field :currency, :string
    field :description, :string
    field :metadata, StripeMock.Metadata, default: %{}
    field :statement_descriptor, :string
    field :transfer_group, :string

    belongs_to :customer, API.Customer
  end

  @doc false
  def create_changeset(charge, attrs) do
    charge
    |> cast(attrs, [
      :amount,
      :currency,
      :capture,
      :customer_id,
      :description,
      :metadata,
      :statement_descriptor,
      :transfer_group
    ])
    |> validate_required([:amount, :currency])
  end

  @doc false
  def update_changeset(charge, attrs) do
    charge
    |> cast(attrs, [
      :customer_id,
      :description,
      :metadata,
      :transfer_group
    ])
    |> validate_required([:amount, :currency])
  end
end
