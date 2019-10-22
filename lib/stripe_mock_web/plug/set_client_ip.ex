defmodule StripeMockWeb.Plug.SetClientIP do
  @moduledoc """
  Sets the client IP address in the params via an extremely frowned upon method.
  """

  def init(options), do: options

  def call(%{params: params} = conn, _arg) do
    params = Map.put(params, "client_ip", get_ip(conn))
    %{conn | params: params}
  end

  defp get_ip(conn) do
    [a, b, c, d | _] = Tuple.to_list(conn.remote_ip)
    "#{a}.#{b}.#{c}.#{d}"
  end
end
