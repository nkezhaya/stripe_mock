defmodule StripeMockWeb.SourceControllerTest do
  use StripeMockWeb.ConnCase
  @moduletag :source

  alias StripeMock.API.Card
  alias StripeMock.CardFixture

  @card_attrs CardFixture.valid_card()
  @update_attrs %{
    name: "New Name",
    address: "New Address"
  }

  setup :create_customer

  describe "index" do
    setup [:create_card]

    test "lists all cards", %{conn: conn, customer: customer} do
      conn = get(conn, Routes.customer_source_path(conn, :index, customer.id, object: "card"))
      data = json_response(conn, 200)["data"]
      assert is_list(data)

      for source <- data do
        assert source["customer"] == customer.id
      end
    end
  end

  describe "create card" do
    test "renders card when data is valid", %{conn: conn, customer: customer} do
      # Get a source token
      %{"id" => token} =
        conn
        |> post(Routes.token_path(conn, :create), card: @card_attrs)
        |> json_response(201)

      %{"id" => id, "object" => "card"} =
        conn
        |> post(Routes.customer_source_path(conn, :create, customer.id), source: token)
        |> json_response(201)

      assert id =~ ~r/^card_/
    end

    test "renders errors when data is invalid", %{conn: conn, customer: customer} do
      response =
        conn
        |> post(Routes.customer_source_path(conn, :create, customer.id), source: "non-token")
        |> json_response(400)

      assert is_map(response["error"])
    end
  end

  describe "update card" do
    setup [:create_card]

    test "renders card when data is valid", %{conn: conn, card: %Card{id: id} = card} do
      conn =
        put(conn, Routes.customer_source_path(conn, :update, card.customer_id, card),
          card: @update_attrs
        )

      assert %{"id" => ^id, "object" => "card"} = json_response(conn, 200)

      conn = get(conn, Routes.customer_source_path(conn, :show, card.customer_id, card))

      assert %{"id" => ^id, "object" => "card"} = json_response(conn, 200)
    end
  end

  describe "delete card" do
    setup [:create_card]

    test "deletes chosen card", %{conn: conn, card: card} do
      conn = delete(conn, Routes.customer_source_path(conn, :delete, card.customer_id, card))
      assert response(conn, 200)

      response =
        conn
        |> get(Routes.customer_source_path(conn, :show, card.customer_id, card))
        |> json_response(200)

      assert response["deleted"]
    end
  end
end
