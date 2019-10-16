defmodule StripeMock.API.Source do
  use StripeMock.Schema

  schema "sources" do
    belongs_to :card, API.Card
    belongs_to :token, API.Card
  end

  @doc false
  def changeset(token, attrs) do
    token
    |> cast(attrs, [:card_id, :token_id])
  end
end
