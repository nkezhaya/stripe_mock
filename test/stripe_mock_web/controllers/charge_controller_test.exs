defmodule StripeMockWeb.ChargeControllerTest do
  use StripeMockWeb.ConnCase
  @moduletag :charge

  setup :create_customer
  setup :create_card

  describe "index" do
    setup :create_charge

    test "lists all charges", %{conn: conn} do
      conn = get(conn, Routes.charge_path(conn, :index))
      assert is_list(json_response(conn, 200)["data"])
    end
  end

  describe "create charge" do
    setup :create_token

    test "renders charge when the customer and card are valid", %{
      conn: conn,
      customer: customer,
      token: token
    } do
      params = create_attrs() |> Map.merge(%{customer_id: customer.id, source: token.id})

      conn = post(conn, Routes.charge_path(conn, :create), params)
      assert %{"id" => id} = json_response(conn, 201)

      conn = get(conn, Routes.charge_path(conn, :show, id))

      assert %{
               "id" => "ch_" <> _id,
               "amount" => 5000,
               "amount_refunded" => 0,
               "currency" => "some currency",
               "customer" => _,
               "description" => "some description",
               "metadata" => %{},
               "statement_descriptor" => "some statement_descriptor",
               "transfer_group" => "some transfer_group"
             } = json_response(conn, 200)
    end

    test "renders charge when the token is valid and no customer is provided", %{
      conn: conn,
      token: token
    } do
      params = create_attrs() |> Map.merge(%{source: token.id})
      conn = post(conn, Routes.charge_path(conn, :create), params)
      assert %{"id" => id} = json_response(conn, 201)

      conn = get(conn, Routes.charge_path(conn, :show, id))

      assert %{
               "id" => _id,
               "amount" => 5000,
               "currency" => "some currency",
               "customer" => nil,
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

    test "renders charge when data is valid", %{conn: conn, charge: charge} do
      conn = put(conn, Routes.charge_path(conn, :update, charge), update_attrs())
      assert %{"id" => "ch_" <> _ = id} = json_response(conn, 200)

      conn = get(conn, Routes.charge_path(conn, :show, id))

      assert %{
               "description" => "some updated description",
               "metadata" => %{"key" => "val"}
             } = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, charge: charge} do
      conn = patch(conn, Routes.charge_path(conn, :update, charge), invalid_attrs())
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  def create_attrs() do
    %{
      amount: 5000,
      capture: true,
      currency: "some currency",
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
      source: nil,
      statement_descriptor: nil,
      transfer_group: nil
    }
  end
end
