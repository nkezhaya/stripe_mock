defmodule StripeMock.API do
  alias StripeMock.API.Operations, as: Ops

  # Customers
  defdelegate list_customers(), to: Ops.Customer
  defdelegate get_customer(id), to: Ops.Customer
  defdelegate get_customer!(id), to: Ops.Customer
  defdelegate create_customer(attrs \\ %{}), to: Ops.Customer
  defdelegate update_customer(customer, attrs \\ %{}), to: Ops.Customer
  defdelegate delete_customer(customer), to: Ops.Customer

  # Tokens
  defdelegate get_token(id), to: Ops.Token
  defdelegate create_token(attrs \\ %{}), to: Ops.Token

  # Cards
  defdelegate list_cards(customer), to: Ops.Card
  defdelegate get_card(id), to: Ops.Card
  defdelegate get_card!(id), to: Ops.Card
  defdelegate create_card(customer, attrs \\ %{}), to: Ops.Card
  defdelegate create_customer_card_from_source(customer, source, metadata \\ %{}), to: Ops.Card
  defdelegate update_card(card, attrs \\ %{}), to: Ops.Card
  defdelegate delete_card(card), to: Ops.Card

  # Sources - TODO
  # defdelegate attach_source(source, customer), to: Ops.Source
  # defdelegate detach_source(source, customer), to: Ops.Source

  # Charges
  defdelegate list_charges(), to: Ops.Charge
  defdelegate get_charge(id), to: Ops.Charge
  defdelegate create_charge(attrs \\ %{}), to: Ops.Charge
  defdelegate update_charge(charge, attrs \\ %{}), to: Ops.Charge

  # Refunds
  defdelegate list_refunds(), to: Ops.Refund
  defdelegate get_refund(id), to: Ops.Refund
  defdelegate create_refund(attrs \\ %{}), to: Ops.Refund
  defdelegate update_refund(refund, attrs \\ %{}), to: Ops.Refund
end
