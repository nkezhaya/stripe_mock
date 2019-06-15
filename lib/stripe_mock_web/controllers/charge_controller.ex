defmodule StripeMockWeb.ChargeController do
  use StripeMockWeb, :controller

  alias StripeMock.API
  alias StripeMock.API.Charge

  plug SMPlug.ConvertParams,
       %{"customer" => "customer_id", "source" => "source_id"} when action in [:create, :update]

  action_fallback StripeMockWeb.FallbackController

  def index(conn, params) do
    page = API.list_charges() |> paginate(params)
    render(conn, "index.json", page: page)
  end

  def create(conn, charge_params) do
    with {:ok, %Charge{} = charge} <- API.create_charge(charge_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.charge_path(conn, :show, charge))
      |> render("show.json", charge: charge)
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, charge} <- API.get_charge(id) do
      render(conn, "show.json", charge: charge)
    end
  end

  def update(conn, %{"id" => id} = charge_params) do
    with {:ok, charge} <- API.get_charge(id),
         {:ok, %Charge{} = charge} <- API.update_charge(charge, charge_params) do
      render(conn, "show.json", charge: charge)
    end
  end
end
