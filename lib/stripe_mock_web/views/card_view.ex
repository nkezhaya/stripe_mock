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
    |> Map.take(~w(id created deleted exp_month exp_year metadata last4 brand)a)
    |> Map.put("object", "card")
    |> Map.put("customer", card.customer_id)
    |> as_map()
  end

  def render("delete.json", %{card: card}) do
    %{id: card.id, object: card.object, deleted: card.deleted}
  end
end
