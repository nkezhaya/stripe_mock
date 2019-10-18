defmodule StripeMock.ID do
  @moduledoc """
  Generates a somewhat Stripe-esque random ID string. Pretty much a base52-encoded UUID.
  """
  alias StripeMock.API

  @spec generate() :: String.t()
  def generate() do
    from_bytes(:crypto.strong_rand_bytes(16))
  end

  @spec from_uuid(String.t()) :: String.t() | none()
  def from_uuid(uuid) do
    {:ok, bytes} = Ecto.UUID.dump(uuid)
    from_bytes(bytes)
  end

  defp from_bytes(bytes) do
    bytes
    |> :erlang.binary_to_list()
    |> Enum.reduce(1, &if(&1 > 0, do: &1 * &2, else: &2))
    |> StripeMock.Base52.encode()
  end

  @spec type(module()) :: atom()
  def type(%{} = map), do: type(map.__struct__)
  def type(API.Card), do: :card
  def type(API.Charge), do: :charge
  def type(API.Customer), do: :customer
  def type(API.PaymentMethod), do: :payment_method
  def type(API.PaymentIntent), do: :payment_intent
  def type(API.Refund), do: :refund
  def type(API.Token), do: :token

  @spec type(map()) :: String.t()
  def prefix(%API.Card{}), do: "card"
  def prefix(%API.Charge{}), do: "ch"
  def prefix(%API.Customer{}), do: "cus"
  def prefix(%API.PaymentMethod{}), do: "pm"
  def prefix(%API.PaymentIntent{}), do: "pi"
  def prefix(%API.Refund{}), do: "re"
  def prefix(%API.Token{}), do: "tok"
end
