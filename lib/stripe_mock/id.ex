defmodule StripeMock.ID do
  @moduledoc """
  Generates a somewhat Stripe-esque random ID string. Pretty much a base52-encoded UUID.
  """

  def generate() do
    :crypto.strong_rand_bytes(16)
    |> :erlang.binary_to_list()
    |> Enum.reduce(1, &(&1 * &2))
    |> StripeMock.Base52.encode()
  end
end
