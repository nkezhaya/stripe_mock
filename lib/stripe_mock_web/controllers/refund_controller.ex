defmodule StripeMockWeb.RefundController do
  use StripeMockWeb, :controller

  alias StripeMock.API
  alias StripeMock.API.Refund

  plug SMPlug.ConvertParams, %{"charge" => "charge_id"} when action in [:create, :update]
  action_fallback StripeMockWeb.FallbackController

  def index(conn, params) do
    page = API.list_refunds() |> paginate(params)
    render(conn, "index.json", page: page)
  end

  def create(conn, refund_params) do
    with {:ok, %Refund{} = refund} <- API.create_refund(refund_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.refund_path(conn, :show, refund))
      |> render("show.json", refund: refund)
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, refund} <- API.get_refund(id) do
      render(conn, "show.json", refund: refund)
    end
  end

  def update(conn, %{"id" => id} = refund_params) do
    with {:ok, refund} <- API.get_refund(id),
         {:ok, %Refund{} = refund} <- API.update_refund(refund, refund_params) do
      render(conn, "show.json", refund: refund)
    end
  end
end
