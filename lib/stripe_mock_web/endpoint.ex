defmodule StripeMockWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :stripe_mock

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  plug StripeMockWeb.Router
end
