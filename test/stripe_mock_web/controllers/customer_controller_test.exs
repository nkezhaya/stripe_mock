defmodule StripeMockWeb.CustomerControllerTest do
  use StripeMockWeb.ConnCase
  @moduletag :customer

  alias StripeMock.API.Customer

  @create_attrs %{
    email: "foo@wat.com"
  }
  @update_attrs %{
    name: "Bar"
  }
  @invalid_attrs %{
    email: "not an email"
  }

  describe "index" do
    setup :create_customer
    setup :create_customer

    test "lists all customers", %{conn: conn} do
      conn = get(conn, Routes.customer_path(conn, :index))
      refute json_response(conn, 200)["data"] == []
    end
  end

  describe "show" do
    setup :create_customer

    test "renders customer data", %{conn: conn, customer: customer} do
      conn = get(conn, Routes.customer_path(conn, :show, customer.id))
      assert %{"id" => "cus_" <> id} = json_response(conn, 200)
    end

    test "renders 404 on not found", %{conn: conn} do
      conn = get(conn, Routes.customer_path(conn, :show, "invalid_id"))
      assert %{} = json_response(conn, 404)
    end
  end

  describe "create customer" do
    test "renders customer when data is valid", %{conn: conn} do
      conn = post(conn, Routes.customer_path(conn, :create), @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)

      conn = get(conn, Routes.customer_path(conn, :show, id))

      assert %{"id" => "cus_" <> id} = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.customer_path(conn, :create), @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update customer" do
    setup [:create_customer]

    test "renders customer when data is valid", %{conn: conn, customer: customer} do
      conn = put(conn, Routes.customer_path(conn, :update, customer), @update_attrs)
      assert %{"id" => "cus_" <> _ = id} = json_response(conn, 200)

      conn = get(conn, Routes.customer_path(conn, :show, id))

      assert %{"id" => "cus_" <> _} = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, customer: customer} do
      conn = put(conn, Routes.customer_path(conn, :update, customer), @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete customer" do
    setup [:create_customer]

    test "deletes chosen customer", %{
      conn: conn,
      customer: %Customer{id: id} = customer
    } do
      conn = delete(conn, Routes.customer_path(conn, :delete, customer))
      assert %{"deleted" => true} = json_response(conn, :ok)

      assert %{"deleted" => true} =
               conn
               |> get(Routes.customer_path(conn, :show, id))
               |> json_response(200)
    end
  end
end
