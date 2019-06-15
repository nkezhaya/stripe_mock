defmodule StripeMock.API.Operations.Card do
  alias StripeMock.Repo
  alias StripeMock.API.Card

  def list_cards(customer) do
    Card
    |> Repo.all()
    |> Enum.filter(&(&1.customer_id == customer.id))
  end

  def get_card(id), do: Repo.get(Card, id)
  def get_card!(id), do: Repo.get!(Card, id)

  def create_card(customer, attrs) do
    %Card{customer_id: customer.id}
    |> Card.create_changeset(attrs)
    |> Repo.insert()
  end

  def create_customer_card_from_source(customer, source, metadata) do
    result =
      source.card
      |> Ecto.Changeset.change(%{customer_id: customer.id, metadata: metadata})
      |> Repo.update()

    source
    |> Ecto.Changeset.change(%{used: true})
    |> Repo.update()

    result
  end

  def update_card(%Card{} = card, attrs) do
    card
    |> Card.update_changeset(attrs)
    |> Repo.update()
  end

  def delete_card(%Card{} = card) do
    Repo.delete(card)
  end
end
