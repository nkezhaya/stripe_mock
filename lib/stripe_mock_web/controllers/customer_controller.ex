defmodule StripeMockWeb.CustomerController do
  use StripeMockWeb, :controller

  alias StripeMock.API
  alias StripeMock.API.Customer

  action_fallback StripeMockWeb.FallbackController

  def index(conn, params) do
    page = API.list_customers() |> paginate(params)
    render(conn, "index.json", page: page)
  end

  def create(conn, customer_params) do
    with {:ok, %Customer{} = customer} <- API.create_customer(customer_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.customer_path(conn, :show, customer))
      |> render("show.json", customer: customer)
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, customer} <- API.get_customer(id) do
      render(conn, "show.json", customer: customer)
    end
  end

  def update(conn, %{"id" => id} = customer_params) do
    with {:ok, customer} <- API.get_customer(id),
         {:ok, customer} <- API.update_customer(customer, customer_params) do
      render(conn, "show.json", customer: customer)
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, customer} <- API.get_customer(id),
         {:ok, customer} <- API.delete_customer(customer) do
      render(conn, "show.json", customer: customer)
    end
  end
end
