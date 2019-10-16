defmodule StripeMock.API.PaymentMethod do
  use StripeMock.Schema

  schema "payment_methods" do
    belongs_to :card, API.Card
    belongs_to :token, API.Token
    belongs_to :source, API.Source

    common_fields()
    timestamps()
  end

  @doc false
  def changeset(token, attrs) do
    token
    |> cast(attrs, [:card_id, :token_id, :source_id])
    |> put_common_fields()
  end
end
