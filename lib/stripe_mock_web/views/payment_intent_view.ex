defmodule StripeMockWeb.PaymentIntentView do
  use StripeMockWeb, :view
  alias StripeMockWeb.PaymentIntentView

  def render("index.json", %{page: page}) do
    %{data: render_many(page.data, PaymentIntentView, "payment_intent.json")}
  end

  def render("show.json", %{payment_intent: payment_intent}) do
    render_one(payment_intent, PaymentIntentView, "payment_intent.json")
  end

  def render("payment_intent.json", %{payment_intent: payment_intent}) do
    payment_intent
    |> as_map("payment_intent")
    |> Map.take(
      ~w(id object amount capture_method confirmation_method currency description metadata payment_method_types statement_descriptor status transfer_group)a
    )
    |> Map.put("customer", payment_intent.customer_id)
    |> Map.merge(%{
      object: "payment_intent",
      payment_method: render_payment_method(payment_intent.payment_method)
    })
  end

  def render_payment_method(payment_method) do
    render(StripeMockWeb.PaymentMethodView, "payment_method.json", payment_method: payment_method)
  end
end
