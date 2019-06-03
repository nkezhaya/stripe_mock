defmodule StripeMock.API.Operations.Refund do
  alias StripeMock.Repo
  alias StripeMock.API.Refund

  def list_refunds do
    Repo.all(Refund)
  end

  def get_refund(id) do
    Repo.fetch(Refund, id)
  end

  def create_refund(attrs \\ %{}) do
    %Refund{}
    |> Refund.create_changeset(attrs)
    |> Repo.insert()
  end

  def update_refund(%Refund{} = refund, attrs) do
    refund
    |> Refund.update_changeset(attrs)
    |> Repo.update()
  end
end
