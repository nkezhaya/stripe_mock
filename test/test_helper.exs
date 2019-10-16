ExUnit.start()

defmodule StripeMock.TestHelper do
  alias StripeMock.API

  @create_attrs %{
    name: "Foo"
  }

  def create_card(%{customer: customer} = ctx) do
    [token: token] = create_token(ctx)
    {:ok, card} = API.create_card(customer, %{source: token.id})
    [card: card]
  end

  def create_customer() do
    {:ok, customer} = API.create_customer(@create_attrs)
    customer
  end

  def create_customer(_) do
    [customer: create_customer()]
  end

  def create_charge(%{customer: customer}) do
    [charge: create_charge(customer)]
  end

  def create_charge(%API.Customer{} = customer) do
    [token: token] = create_token()

    {:ok, charge} =
      API.create_charge(%{
        amount: 5000,
        capture: true,
        currency: "some currency",
        customer_id: customer.id,
        description: "some description",
        metadata: %{},
        source: token.id,
        statement_descriptor: "some statement_descriptor",
        transfer_group: "some transfer_group"
      })

    charge
  end

  def create_payment_intent(%{customer: customer}) do
    [payment_intent: create_payment_intent(customer)]
  end

  def create_payment_intent(%API.Customer{} = customer) do
    [token: token] = create_token()

    {:ok, charge} =
      API.create_payment_intent(%{
        amount: 5000,
        currency: "some currency",
        customer_id: customer.id,
        payment_method_id: token.id
      })

    charge
  end

  def create_refund(%{charge: charge}) do
    params = %{
      amount: 5000,
      charge_id: charge.id,
      description: "some description",
      metadata: %{}
    }

    {:ok, refund} = API.create_refund(params)
    {:ok, refund: refund}
  end

  def create_token(_ctx \\ %{}) do
    params = %{card: StripeMock.CardFixture.valid_card(), client_ip: "0.0.0.0"}
    {:ok, token} = API.create_token(params)
    [token: token]
  end
end
