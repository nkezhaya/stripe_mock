defmodule StripeMock.API.PaymentIntent do
  use StripeMock.Schema

  schema "payment_intents" do
    field :amount, :integer
    field :capture_method, :string, default: "automatic"
    field :confirm, :boolean, virtual: true, default: false
    field :confirmation_method, :string, default: "automatic"
    field :currency, :string
    field :payment_method_types, {:array, :string}, default: ["card"]
    field :statement_descriptor, :string
    field :status, :string
    field :transfer_data, :map
    field :transfer_group, :string

    belongs_to(:customer, API.Customer)
    belongs_to(:payment_method, API.PaymentMethod)
    has_many(:charges, API.Charge)

    common_fields()
    timestamps()
  end

  @doc false
  def changeset(payment_intent, attrs) do
    payment_intent
    |> cast(attrs, [
      :amount,
      :confirm,
      :confirmation_method,
      :currency,
      :customer_id,
      :description,
      :metadata,
      :payment_method_id,
      :statement_descriptor,
      :transfer_data,
      :transfer_group
    ])
    |> validate_inclusion(:capture_method, ~w(automatic manual))
    |> validate_inclusion(:confirmation_method, ~w(automatic manual))
    |> set_payment_method()
    |> validate_required([:payment_method_id])
    |> put_common_fields()
  end

  @doc false
  def status_changeset(payment_intent, status) do
    payment_intent
    |> change(%{status: status})
    |> put_common_fields()
  end

  @doc false
  def capture_changeset(payment_intent, charge) do
  end

  defp set_payment_method(changeset) do
    case get_change(changeset, :payment_method_id) do
      nil ->
        changeset

      id ->
        card = Repo.get(API.Card, id)
        token = Repo.get(API.Token, id)

        case find_payment_method(card || token) do
          nil -> add_error(changeset, :payment_method_id, "not found")
          payment_method -> put_change(changeset, :payment_method_id, payment_method.id)
        end
    end
  end

  defp find_payment_method(%API.Card{} = card),
    do: Repo.get_by(API.PaymentMethod, card_id: card.id)

  defp find_payment_method(%API.Token{} = token),
    do: Repo.get_by(API.PaymentMethod, token_id: token.id)

  defp find_payment_method(_),
    do: nil
end
