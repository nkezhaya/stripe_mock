defmodule StripeMockWeb.RefundView do
  use StripeMockWeb, :view
  alias StripeMockWeb.RefundView

  def render("index.json", %{conn: conn, page: page}) do
    render_page(conn, page, RefundView, "refund.json")
  end

  def render("show.json", %{refund: refund}) do
    render_one(refund, RefundView, "refund.json")
  end

  def render("refund.json", %{refund: refund}) do
    %{
      id: refund.id,
      charge: refund.charge_id,
      amount: refund.amount,
      metadata: refund.metadata,
      reason: refund.reason
    }
  end
end
