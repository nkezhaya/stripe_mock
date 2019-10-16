defmodule StripeMock.API.Operations.Card do
  import Ecto.Query
  alias Ecto.Multi
  alias StripeMock.Repo
  alias StripeMock.API.{Card, PaymentMethod}

  def list_cards(customer) do
    Card
    |> where([c], not c.deleted)
    |> where([c], c.customer_id == ^customer.id)
    |> Repo.all()
  end

  def get_card(id), do: Repo.fetch(Card, id)
  def get_card!(id), do: Repo.get!(Card, id)

  def create_card(customer, attrs) do
    Multi.new()
    |> Multi.insert(:card, Card.create_changeset(%Card{customer_id: customer.id}, attrs))
    |> Multi.run(:payment_method, fn _repo, %{card: card} ->
      %PaymentMethod{}
      |> PaymentMethod.changeset(%{card_id: card.id})
      |> Repo.insert()
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{card: card}} -> {:ok, card}
      {:error, _, value, _} -> {:error, value}
    end
  end

  def create_customer_card_from_source(customer, source, metadata) do
    result =
      source.card
      |> Ecto.Changeset.change(%{customer_id: customer.id, metadata: metadata || %{}})
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
