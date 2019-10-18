defmodule StripeMockWeb.ChargeView do
  use StripeMockWeb, :view
  alias StripeMockWeb.ChargeView

  def render("index.json", %{page: page}) do
    %{data: render_many(page.data, ChargeView, "charge.json")}
  end

  def render("show.json", %{charge: charge}) do
    render_one(charge, ChargeView, "charge.json")
  end

  def render("charge.json", %{charge: charge}) do
    charge
    |> as_map("charge")
    |> Map.take(
      ~w(id object amount currency capture description metadata statement_descriptor transfer_group)a
    )
    |> Map.merge(%{
      customer: charge.customer_id,
      outcome: render_outcome(charge),
      payment_method:
        if(charge.card, do: render(StripeMockWeb.CardView, "card.json", card: charge.card))
    })
  end

  defp render_outcome(_charge) do
    %{
      network_status: "approved_by_network",
      reason: nil,
      risk_level: "normal",
      risk_score: 0,
      seller_message: "Approved by network.",
      type: "authorized"
    }
  end
end
