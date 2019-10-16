defmodule StripeMockWeb.PaymentIntentController do
  use StripeMockWeb, :controller

  alias StripeMock.API

  plug SMPlug.ConvertParams,
       %{"customer" => "customer_id", "payment_method" => "payment_method_id"}
       when action in [:create, :update]

  action_fallback StripeMockWeb.FallbackController

  def index(conn, params) do
    page = API.list_payment_intents() |> paginate(params)
    render(conn, "index.json", page: page)
  end

  def create(conn, payment_intent_params) do
    with {:ok, payment_intent} <- API.create_payment_intent(payment_intent_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.payment_intent_path(conn, :show, payment_intent))
      |> render("show.json", payment_intent: payment_intent)
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, payment_intent} <- API.get_payment_intent(id) do
      render(conn, "show.json", payment_intent: payment_intent)
    end
  end

  def update(conn, %{"id" => id} = payment_intent_params) do
    with {:ok, payment_intent} <- API.get_payment_intent(id),
         {:ok, payment_intent} <-
           API.update_payment_intent(payment_intent, payment_intent_params) do
      render(conn, "show.json", payment_intent: payment_intent)
    end
  end

  def confirm(conn, %{"id" => id}) do
    with {:ok, payment_intent} <- API.get_payment_intent(id),
         {:ok, payment_intent} <- API.confirm_payment_intent(payment_intent) do
      render(conn, "show.json", payment_intent: payment_intent)
    end
  end

  def capture(conn, %{"id" => id}) do
    with {:ok, payment_intent} <- API.get_payment_intent(id),
         {:ok, payment_intent} <- API.capture_payment_intent(payment_intent) do
      render(conn, "show.json", payment_intent: payment_intent)
    end
  end
end
