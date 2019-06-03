defmodule StripeMockWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use StripeMockWeb, :controller
  alias StripeMock.Error

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(StripeMockWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(StripeMockWeb.ErrorView)
    |> render(:"404")
  end

  def call(conn, {:error, %Error{} = error}) do
    conn
    |> put_status(Error.http_status(error))
    |> put_view(StripeMockWeb.ErrorView)
    |> render(:error, error: error)
  end
end
