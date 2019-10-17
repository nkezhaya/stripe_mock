defmodule StripeMockWeb.Router do
  use StripeMockWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug StripeMockWeb.Plug.Auth
    plug StripeMockWeb.Plug.EnsureMigratorFinished
  end

  scope "/v1", StripeMockWeb do
    pipe_through :api

    resources "/customers", CustomerController do
      resources "/sources", SourceController
      post "/sources/:id", SourceController, :update
    end

    resources "/charges", ChargeController, except: [:delete]
    resources "/refunds", RefundController, except: [:delete]
    resources "/sources", SourceController, only: [:show]
    resources "/tokens", TokenController, only: [:create, :show]

    resources "/payment_intents", PaymentIntentController, except: [:delete]
    post "/payment_intents/:id/capture", PaymentIntentController, :capture
    post "/payment_intents/:id/confirm", PaymentIntentController, :confirm

    post "/charges/:id", ChargeController, :update
    post "/customers/:id", CustomerController, :update
    post "/refunds/:id", RefundController, :update
  end
end
