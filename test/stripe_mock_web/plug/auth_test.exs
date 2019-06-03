defmodule StripeMockWeb.AuthTest do
  use StripeMockWeb.ConnCase
  @moduletag :auth

  setup do
    [conn: build_conn()]
  end

  test "bearer auth", %{conn: conn} do
    conn
    |> put_req_header("authorization", "bearer sk_test_123")
    |> get(Routes.customer_path(conn, :index))
    |> json_response(200)
    |> assert
  end

  test "bearer fail", %{conn: conn} do
    conn
    |> put_req_header("authorization", "bearer foo")
    |> get(Routes.customer_path(conn, :index))
    |> json_response(401)
    |> assert
  end

  test "basic auth", %{conn: conn} do
    # sk_test_123:
    conn
    |> put_req_header("authorization", "basic c2tfdGVzdF8xMjM6")
    |> get(Routes.customer_path(conn, :index))
    |> json_response(200)
    |> assert
  end

  test "basic auth pw", %{conn: conn} do
    # sk_test_123:pw doesn't matter
    conn
    |> put_req_header("authorization", "basic c2tfdGVzdF8xMjM6cHcgZG9lc24ndCBtYXR0ZXI=")
    |> get(Routes.customer_path(conn, :index))
    |> json_response(200)
    |> assert
  end

  test "basic fail", %{conn: conn} do
    # foo
    conn
    |> put_req_header("authorization", "basic Zm9v")
    |> get(Routes.customer_path(conn, :index))
    |> json_response(401)
    |> assert
  end
end
