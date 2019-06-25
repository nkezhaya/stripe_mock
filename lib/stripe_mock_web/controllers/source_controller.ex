defmodule StripeMockWeb.SourceController do
  use StripeMockWeb, :controller

  alias StripeMock.API

  plug :set_customer when action != :show
  action_fallback StripeMockWeb.FallbackController

  # GET /v1/customers/cus_F7ux2fMKFvhMMP/sources?object=card
  def index(conn, %{"object" => "card"} = params) do
    page = API.list_cards(conn.assigns.customer) |> paginate(params)

    conn
    |> put_view(StripeMockWeb.CardView)
    |> render("index.json", page: page)
  end

  # POST /v1/customers/cus_F9PeLuQPxok2xa/sources
  def create(conn, %{"source" => token} = params) do
    %{customer: customer} = conn.assigns

    case API.get_token(token) do
      {:ok, source} ->
        with {:ok, source} <-
               API.create_customer_card_from_source(customer, source, params["metadata"]) do
          conn
          |> put_status(:created)
          |> render("show.json", source: source)
        end

      {:error, :not_found} ->
        {:error,
         %StripeMock.Error{code: :resource_missing, type: :invalid_request_error, param: "source"}}
    end
  end

  def show(conn, %{"id" => id}) do
    card = API.get_card!(id)

    conn
    |> put_view(StripeMockWeb.CardView)
    |> render("show.json", card: card)
  end

  def update(conn, %{"id" => id, "card" => card_params}) do
    card = API.get_card!(id)

    with {:ok, source} <- API.update_card(card, card_params) do
      render(conn, "show.json", source: source)
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, card} <- API.get_card(id),
         {:ok, source} <- API.delete_card(card) do
      render(conn, "show.json", source: source)
    end
  end

  defp set_customer(%{params: %{"customer_id" => customer_id}} = conn, _arg) do
    case API.get_customer(customer_id) do
      {:ok, customer} ->
        assign(conn, :customer, customer)

      _ ->
        conn
        |> put_status(404)
        |> put_view(StripeMockWeb.ErrorView)
        |> render(:"404", [])
        |> halt()
    end
  end
end
