defmodule StripeMock.API.Operations.Charge do
  alias StripeMock.Repo
  alias StripeMock.API.Charge

  def list_charges do
    Repo.all(Charge)
  end

  def get_charge(id) do
    Repo.fetch(Charge, id)
  end

  def create_charge(attrs \\ %{}) do
    %Charge{}
    |> Charge.create_changeset(attrs)
    |> Repo.insert()
  end

  def update_charge(%Charge{} = charge, attrs) do
    charge
    |> Charge.create_changeset(attrs)
    |> Repo.update()
  end
end
