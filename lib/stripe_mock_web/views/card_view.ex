defmodule StripeMockWeb.CardView do
  use StripeMockWeb, :view
  alias __MODULE__

  def render("index.json", %{conn: conn, page: page}) do
    render_page(conn, page, CardView, "card.json")
  end

  def render("show.json", %{card: card}) do
    render_one(card, CardView, "card.json")
  end

  def render("card.json", %{card: card}) do
    card
    |> as_map("card")
    |> Map.take(~w(id object created deleted exp_month exp_year metadata last4 brand)a)
    |> Map.put("customer", card.customer_id)
  end

  def render("delete.json", %{card: card}) do
    %{id: card.id, object: card.object, deleted: card.deleted}
  end
end
