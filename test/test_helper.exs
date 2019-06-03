ExUnit.start()

defmodule StripeMock.TestHelper do
  alias StripeMock.API

  @create_attrs %{
    name: "Foo"
  }

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
    {:ok, charge} =
      API.create_charge(%{
        amount: 5000,
        capture: true,
        currency: "some currency",
        customer: customer.id,
        description: "some description",
        metadata: %{},
        statement_descriptor: "some statement_descriptor",
        transfer_group: "some transfer_group"
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
end
