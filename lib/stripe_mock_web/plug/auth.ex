defmodule StripeMockWeb.Plug.Auth do
  @moduledoc """
  Pretends to do auth stuff.
  """

  use Phoenix.Controller

  def init(options), do: options

  def call(conn, _arg) do
    if authed?(conn) do
      conn
    else
      conn
      |> put_status(:unauthorized)
      |> put_view(StripeMockWeb.ErrorView)
      |> render(:error, error: StripeMock.Error.unauthorized())
      |> halt()
    end
  end

  defp authed?(conn) do
    case get_key(conn) do
      "sk_test_" <> _ -> true
      _ -> false
    end
  end

  defp get_key(conn) do
    conn.req_headers
    |> Enum.find_value(fn
      {"authorization", auth} when is_bitstring(auth) ->
        case String.downcase(auth) do
          "basic " <> _ ->
            {_, base64_key} = String.split_at(auth, 6)

            case Base.decode64(base64_key) do
              {:ok, key} -> key
              _ -> false
            end

          "bearer " <> _ ->
            {_, key} = String.split_at(auth, 7)
            key

          _ ->
            false
        end

      _ ->
        false
    end)
  end
end
