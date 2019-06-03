defmodule StripeMockWeb.Router do
  use StripeMockWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug StripeMockWeb.Plug.Auth
  end

  scope "/v1", StripeMockWeb do
    pipe_through :api

    resources "/customers", CustomerController do
      resources "/sources", SourceController
    end

    resources "/charges", ChargeController, except: [:delete]
    resources "/refunds", RefundController, except: [:delete]
    resources "/sources", SourceController, only: [:show]
    resources "/tokens", TokenController, only: [:create, :show]
  end
end
