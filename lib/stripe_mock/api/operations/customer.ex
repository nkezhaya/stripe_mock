defmodule StripeMock.API.Operations.Customer do
  alias StripeMock.Repo
  alias StripeMock.API.Customer

  def list_customers() do
    Repo.all(Customer)
  end

  def get_customer(id), do: Repo.fetch(Customer, id)
  def get_customer!(id), do: Repo.get!(Customer, id)

  def create_customer(attrs \\ %{}) do
    %Customer{}
    |> Customer.changeset(attrs)
    |> Repo.insert()
  end

  def update_customer(%Customer{} = customer, attrs) do
    customer
    |> Customer.changeset(attrs)
    |> Repo.update()
  end

  def delete_customer(%Customer{} = customer) do
    Repo.delete(customer)
  end
end
