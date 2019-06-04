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
    refund
    |> Map.take(~w(id created amount metadata reason)a)
    |> Map.put(:charge, refund.charge_id)
  end
end
