defmodule StripeMockWeb.PaymentIntentControllerTest do
  use StripeMockWeb.ConnCase
  @moduletag :payment_intent

  setup :create_customer
  setup :create_card

  describe "index" do
    setup :create_payment_intent

    test "lists all payment intents", %{conn: conn} do
      conn = get(conn, Routes.payment_intent_path(conn, :index))
      assert is_list(json_response(conn, 200)["data"])
    end
  end

  describe "create payment intent" do
    setup :create_token

    test "renders payment intent when the customer and card are valid", %{
      conn: conn,
      customer: customer,
      token: token
    } do
      params = create_attrs() |> Map.merge(%{customer_id: customer.id, payment_method: token.id})

      conn = post(conn, Routes.payment_intent_path(conn, :create), params)
      assert %{"id" => id} = json_response(conn, 201)

      conn = get(conn, Routes.payment_intent_path(conn, :show, id))

      assert %{
               "id" => id,
               "amount" => 5000,
               "currency" => "some currency",
               "customer" => _,
               "description" => "some description",
               "metadata" => %{},
               "statement_descriptor" => "some statement_descriptor",
               "transfer_group" => "some transfer_group"
             } = json_response(conn, 200)
    end

    test "renders payment intent when the token is valid and no customer is provided", %{
      conn: conn,
      token: token
    } do
      params = create_attrs() |> Map.merge(%{payment_method: token.id})
      conn = post(conn, Routes.payment_intent_path(conn, :create), params)
      assert %{"id" => id} = json_response(conn, 201)

      conn = get(conn, Routes.payment_intent_path(conn, :show, id))

      assert %{
               "id" => id,
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
      conn = post(conn, Routes.payment_intent_path(conn, :create), invalid_attrs())
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update payment intent" do
    setup [:create_payment_intent]

    test "renders payment intent when data is valid", %{
      conn: conn,
      payment_intent: payment_intent
    } do
      conn = put(conn, Routes.payment_intent_path(conn, :update, payment_intent), update_attrs())
      assert %{"id" => "pi_" <> _ = id} = json_response(conn, 200)

      conn = get(conn, Routes.payment_intent_path(conn, :show, id))

      assert %{
               "description" => "some updated description",
               "metadata" => %{"key" => "val"}
             } = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, payment_intent: payment_intent} do
      conn =
        patch(conn, Routes.payment_intent_path(conn, :update, payment_intent), invalid_attrs())

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "confirms payment intent", %{conn: conn, payment_intent: payment_intent} do
      conn = post(conn, Routes.payment_intent_path(conn, :confirm, payment_intent), %{})

      assert %{"status" => "requires_action"} = json_response(conn, 200)
    end

    test "captures payment intent", %{conn: conn, payment_intent: payment_intent} do
      conn
      |> post(Routes.payment_intent_path(conn, :confirm, payment_intent), %{})
      |> json_response(:ok)

      conn = post(conn, Routes.payment_intent_path(conn, :capture, payment_intent), %{})

      assert %{"status" => "succeeded", "charges" => %{"data" => [charge]}} =
               json_response(conn, 200)

      assert charge
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
      payment_method: nil,
      statement_descriptor: nil,
      transfer_group: nil
    }
  end
end
