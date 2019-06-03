defmodule StripeMockWeb.TokenController do
  use StripeMockWeb, :controller

  alias StripeMock.API

  action_fallback StripeMockWeb.FallbackController
  plug SMPlug.SetClientIP

  def create(conn, params) do
    with {:ok, token} <- API.create_token(params) do
      conn
      |> put_status(:created)
      |> render("show.json", token: token)
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, token} <- API.get_token(id) do
      render(conn, "show.json", token: token)
    end
  end
end
