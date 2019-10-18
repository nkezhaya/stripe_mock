defmodule StripeMockWeb.CustomerView do
  use StripeMockWeb, :view
  alias StripeMock.{API, Pagination}
  alias StripeMockWeb.{CustomerView, CardView}

  def render("index.json", %{conn: conn, page: page}) do
    render_page(conn, page, CustomerView, "customer.json")
  end

  def render("show.json", %{conn: conn, customer: customer}) do
    render_one(customer, CustomerView, "customer.json", conn: conn)
  end

  def render("customer.json", %{conn: conn, customer: customer}) do
    sources = API.list_cards(customer) |> Pagination.paginate()

    customer
    |> as_map("customer")
    |> Map.put(:sources, render_page(conn, sources, CardView, "card.json"))
  end
end
