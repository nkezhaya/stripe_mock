defmodule StripeMockWeb.TokenView do
  use StripeMockWeb, :view
  alias StripeMockWeb.{CardView, TokenView}

  def render("index.json", %{conn: conn, page: page}) do
    render_page(conn, page, TokenView, "token.json")
  end

  def render("show.json", %{token: token}) do
    render_one(token, TokenView, "token.json")
  end

  def render("token.json", %{token: token}) do
    object = %{
      id: token.id,
      object: "token",
      client_ip: token.client_ip,
      created: token.created,
      type: token.type,
      used: token.used
    }

    if token.card do
      card = render(CardView, "card.json", card: token.card)
      Map.put(object, :card, card)
    else
      object
    end
  end
end
