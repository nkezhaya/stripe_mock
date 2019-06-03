defmodule StripeMockWeb.ChargeControllerTest do
  use StripeMockWeb.ConnCase
  @moduletag :charge

  alias StripeMock.API.Charge

  setup :create_customer

  describe "index" do
    test "lists all charges", %{conn: conn} do
      conn = get(conn, Routes.charge_path(conn, :index))
      assert is_list(json_response(conn, 200)["data"])
    end
  end

  describe "create charge" do
    test "renders charge when data is valid", %{conn: conn, customer: customer} do
      conn = post(conn, Routes.charge_path(conn, :create), create_attrs(customer.id))
      assert %{"id" => id} = json_response(conn, 201)

      conn = get(conn, Routes.charge_path(conn, :show, id))

      assert %{
               "id" => id,
               "amount" => 5000,
               "capture" => true,
               "currency" => "some currency",
               "customer" => "cus_" <> _,
               "description" => "some description",
               "metadata" => %{},
               "statement_descriptor" => "some statement_descriptor",
               "transfer_group" => "some transfer_group"
             } = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.charge_path(conn, :create), invalid_attrs())
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update charge" do
    setup [:create_charge]

    test "renders charge when data is valid", %{conn: conn, charge: %Charge{id: id} = charge} do
      conn = put(conn, Routes.charge_path(conn, :update, charge), update_attrs())
      assert %{"id" => ^id} = json_response(conn, 200)

      conn = get(conn, Routes.charge_path(conn, :show, id))

      assert %{
               "description" => "some updated description",
               "metadata" => %{"key" => "val"}
             } = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, charge: charge} do
      conn = put(conn, Routes.charge_path(conn, :update, charge), invalid_attrs())
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  def create_attrs(customer_id) do
    %{
      amount: 5000,
      capture: true,
      currency: "some currency",
      customer: customer_id,
      description: "some description",
      metadata: %{},
      statement_descriptor: "some statement_descriptor",
      transfer_group: "some transfer_group"
    }
  end

  def update_attrs() do
    %{
      description: "some updated description",
      metadata: %{"key" => "val"}
    }
  end

  def invalid_attrs() do
    %{
      amount: nil,
      capture: nil,
      currency: nil,
      customer: nil,
      description: nil,
      metadata: nil,
      statement_descriptor: nil,
      transfer_group: nil
    }
  end
end
