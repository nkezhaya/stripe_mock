defmodule StripeMock.API.Card do
  use StripeMock.Schema

  schema "cards" do
    field :brand, :string
    field :deleted, :boolean
    field :metadata, :map, default: %{}
    field :last4, :string
    field :source, :string

    field :number, :string
    field :exp_month, :integer
    field :exp_year, :integer
    field :cvc, :string

    belongs_to :customer, API.Customer

    timestamps()
  end

  @doc false
  def create_changeset(card, attrs) do
    card
    |> cast(attrs, [:source, :metadata])
    |> validate_required([:source, :metadata])
  end

  @doc false
  def update_changeset(card, attrs) do
    card
    |> cast(attrs, [])
    |> validate_required([])
  end

  @doc false
  def token_changeset(card, attrs) do
    card
    |> cast(attrs, [:number, :exp_month, :exp_year, :cvc])
    |> validate_required([:number, :exp_month, :exp_year, :cvc])
    |> set_brand()
    |> set_last4()
  end

  defp set_brand(changeset) do
    brand =
      case get_field(changeset, :number) do
        "4242424242424242" -> "Visa"
        "4000056655665556" -> "Visa"
        "5555555555554444" -> "Mastercard"
        "2223003122003222" -> "Mastercard"
        "5200828282828210" -> "Mastercard"
        "5105105105105100" -> "Mastercard"
        "378282246310005" -> "American Express"
        "371449635398431" -> "American Express"
        "6011111111111117" -> "Discover"
        "6011000990139424" -> "Discover"
        "30569309025904" -> "Diners Club"
        "38520000023237" -> "Diners Club"
        "3566002020360505" -> "JCB"
        "6200000000000005" -> "UnionPay"
      end

    put_change(changeset, :brand, brand)
  end

  defp set_last4(changeset) do
    case get_field(changeset, :number) do
      number when is_bitstring(number) ->
        last4 = String.split_at(number, -4) |> elem(1)
        put_change(changeset, :last4, last4)

      _ ->
        changeset
    end
  end
end
