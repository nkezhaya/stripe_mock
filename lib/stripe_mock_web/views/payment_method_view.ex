defmodule StripeMockWeb.PaymentMethodView do
  use StripeMockWeb, :view
  alias StripeMockWeb.PaymentMethodView

  def render("index.json", %{page: page}) do
    %{data: render_many(page.data, PaymentMethodView, "payment_method.json")}
  end

  def render("show.json", %{payment_method: payment_method}) do
    render_one(payment_method, PaymentMethodView, "payment_method.json")
  end

  def render("payment_method.json", %{payment_method: payment_method}) do
    card = payment_method.card || payment_method.token.card
    payment_object = render(StripeMockWeb.CardView, "card.json", card: card)

    payment_method
    |> Map.take(~w(id created description metadata)a)
    |> as_map()
    |> Map.put(:card, payment_object)
  end

  def do_render(%API.PaymentMethod{card: card}) when not is_nil(card) do
    do_render(card)
  end

  def do_render(%API.PaymentMethod{token: token}) when not is_nil(token) do
    do_render(token.card)
  end
end
