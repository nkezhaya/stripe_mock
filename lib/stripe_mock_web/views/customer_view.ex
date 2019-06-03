defmodule StripeMockWeb.CustomerView do
  use StripeMockWeb, :view
  alias StripeMockWeb.CustomerView

  def render("index.json", %{conn: conn, page: page}) do
    render_page(conn, page, CustomerView, "customer.json")
  end

  def render("show.json", %{customer: customer}) do
    render_one(customer, CustomerView, "customer.json")
  end

  def render("customer.json", %{customer: customer}) do
    customer |> as_map()
  end
end
