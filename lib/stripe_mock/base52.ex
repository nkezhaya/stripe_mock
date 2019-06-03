defmodule StripeMock.Base52 do
  @chars '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
  @base52_alphabet @chars -- 'AEIOUaeiou'

  @doc """
  Encodes an integer into a base52 string.

      iex> encode(0)
      "0"
      iex> encode(1000000000)
      "2clyTD"
  """
  def encode(0), do: "0"

  def encode(integer) when is_integer(integer) do
    do_encode(integer, '') |> to_string()
  end

  defp do_encode(integer, encoded) when integer > 0 do
    encoded = [Enum.at(@base52_alphabet, rem(integer, 52)) | encoded]
    do_encode(Integer.floor_div(integer, 52), encoded)
  end

  defp do_encode(0, encoded), do: encoded
end
