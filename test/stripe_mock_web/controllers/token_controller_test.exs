defmodule StripeMockWeb.TokenControllerTest do
  use StripeMockWeb.ConnCase
  @moduletag :token

  @card_attrs StripeMock.CardFixture.valid_card()

  describe "create token" do
    test "accepts card data and sets type to card", %{conn: conn} do
      conn = post(conn, Routes.token_path(conn, :create), card: @card_attrs)
      assert %{"id" => id, "type" => "card"} = json_response(conn, 201)

      conn = get(conn, Routes.token_path(conn, :show, id))

      assert %{
               "id" => "tok_" <> _,
               "client_ip" => "127.0.0.1",
               "created" => created,
               "object" => "token",
               "type" => "card",
               "used" => false,
               "card" => %{"id" => "card_" <> _}
             } = json_response(conn, 200)

      assert is_integer(created)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.token_path(conn, :create), %{})
      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end
