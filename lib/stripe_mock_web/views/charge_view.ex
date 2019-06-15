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
    %{
      id: charge.id,
      amount: charge.amount,
      currency: charge.currency,
      capture: charge.capture,
      customer: charge.customer_id,
      description: charge.description,
      metadata: charge.metadata,
      object: "charge",
      outcome: render_outcome(charge),
      source: render(StripeMockWeb.CardView, "card.json", card: charge.source),
      statement_descriptor: charge.statement_descriptor,
      transfer_group: charge.transfer_group
    }
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
