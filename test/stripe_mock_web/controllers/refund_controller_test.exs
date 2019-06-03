defmodule StripeMockWeb.RefundControllerTest do
  use StripeMockWeb.ConnCase
  @moduletag :refund

  alias StripeMock.API.Refund

  setup :create_customer
  setup :create_charge

  describe "index" do
    test "lists all refunds", %{conn: conn} do
      conn = get(conn, Routes.refund_path(conn, :index))
      assert is_list(json_response(conn, 200)["data"])
    end
  end

  describe "create refund" do
    test "renders refund when data is valid", %{conn: conn, charge: charge} do
      conn = post(conn, Routes.refund_path(conn, :create), create_attrs(charge.id))
      assert %{"id" => id} = json_response(conn, 201)

      conn = get(conn, Routes.refund_path(conn, :show, id))

      assert %{
               "id" => "re_" <> _,
               "amount" => 5000,
               "charge" => "ch_" <> _,
               "metadata" => %{}
             } = json_response(conn, 200)
    end

    test "amount defaults to full amount of the charge", %{conn: conn, charge: charge} do
      params = %{create_attrs(charge.id) | amount: nil}
      conn = post(conn, Routes.refund_path(conn, :create), params)
      amount = charge.amount
      assert %{"id" => id, "amount" => ^amount} = json_response(conn, 201)
      refute is_nil(charge.amount)

      conn = get(conn, Routes.refund_path(conn, :show, id))

      assert %{
               "id" => "re_" <> _,
               "amount" => ^amount,
               "charge" => "ch_" <> _,
               "metadata" => %{}
             } = json_response(conn, 200)
    end

    test "refunds limited to charge amount", %{conn: conn, charge: charge} do
      params = %{create_attrs(charge.id) | amount: nil}

      conn
      |> post(Routes.refund_path(conn, :create), params)
      |> json_response(:created)

      params = %{create_attrs(charge.id) | amount: 1}
      conn = post(conn, Routes.refund_path(conn, :create), params)
      amount_errors = json_response(conn, 422)["errors"]["amount"]
      assert is_list(amount_errors) and amount_errors != []
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.refund_path(conn, :create), invalid_attrs())
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update refund" do
    setup [:create_refund]

    test "renders refund when data is valid", %{conn: conn, refund: %Refund{id: id} = refund} do
      assert refund.metadata == %{}

      conn = put(conn, Routes.refund_path(conn, :update, refund), %{metadata: %{"key" => "val"}})
      assert %{"id" => ^id} = json_response(conn, 200)

      conn = get(conn, Routes.refund_path(conn, :show, id))

      assert %{"metadata" => %{"key" => "val"}} = json_response(conn, 200)
    end
  end

  def create_attrs(charge_id) do
    %{
      amount: 5000,
      charge: charge_id,
      description: "some description",
      metadata: %{}
    }
  end

  def invalid_attrs() do
    %{
      amount: nil,
      charge: nil,
      description: nil,
      metadata: nil
    }
  end
end
