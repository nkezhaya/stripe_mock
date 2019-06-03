defmodule StripeMockWeb.Plug.ConvertParams do
  @moduledoc """
  Moves params from one key to the other before they hit the changeset
  functions. For example, `%{"customer_id" => customer_id}` should be changed
  to `%{"customer" => customer_id}` for setting the customer in a way Stripe
  would expect.
  """

  def init(options) when is_map(options) do
    options
  end

  def call(conn, conversions) do
    params =
      for {k, v} <- conn.params, into: %{} do
        case Map.get(conversions, k) do
          nil -> {k, v}
          new_key -> {new_key, v}
        end
      end

    %{conn | params: params}
  end
end
