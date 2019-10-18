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
    token
    |> as_map("token")
    |> Map.take(~w(id object card client_ip created type used)a)
    |> case do
      %{card: %API.Card{}} = token ->
        card = render(CardView, "card.json", card: token.card)
        %{token | card: card}

      token ->
        token
    end
  end
end
