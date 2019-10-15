defmodule StripeMock.API.PaymentIntent do
  use StripeMock.Schema

  @primary_key {:id, :binary_id, autogenerate: false}
  schema "payment_intents" do
    field :amount, :integer
    field :capture, :boolean, default: false
    field :capture_method, :string
    field :confirmation_method, :string
    field :currency, :string
    field :description, :string
    field :metadata, StripeMock.Type.Metadata, default: %{}
    field :payment_method_types, {:array, :string}, default: ["card"]
    field :statement_descriptor, :string
    field :transfer_group, :string
  end

  @doc false
  def changeset(payment_intent, attrs) do
    payment_intent
    |> cast(attrs, [:amount, :confirm, :confirmation_method, :currency])
  end

  @doc false
  def status_changeset(payment_intent, status) do
    change(payment_intent, %{status: status})
  end

  @doc false
  def capture_changeset(payment_intent, charge) do
  end
end
