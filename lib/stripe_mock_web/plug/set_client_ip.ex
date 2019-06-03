defmodule StripeMockWeb.Plug.SetClientIP do
  @moduledoc """
  Sets the client IP address in the params via an extremely frowned upon method.
  """

  def init(options), do: options

  def call(%{params: params} = conn, _arg) do
    [a, b, c, d | _] = Tuple.to_list(conn.remote_ip)
    params = Map.put(params, "client_ip", "#{a}.#{b}.#{c}.#{d}")
    %{conn | params: params}
  end
end
