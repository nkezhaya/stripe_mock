defmodule StripeMock.API.Operations.Charge do
  alias StripeMock.Repo
  alias StripeMock.API.Charge

  def list_charges() do
    Charge
    |> Repo.all()
    |> preload_source()
  end

  def get_charge(id) do
    with {:ok, charge} <- Repo.fetch(Charge, id) do
      {:ok, preload_source(charge)}
    end
  end

  def create_charge(attrs \\ %{}) do
    %Charge{}
    |> Charge.create_changeset(attrs)
    |> Repo.insert()
    |> preload_source()
  end

  def update_charge(%Charge{} = charge, attrs) do
    charge
    |> Charge.update_changeset(attrs)
    |> Repo.update()
    |> preload_source()
  end

  defp preload_source({:ok, charge}) do
    {:ok, preload_source(charge)}
  end

  defp preload_source(%Charge{} = charge) do
    Repo.preload(charge, [:card, :token])
  end

  defp preload_source([_ | _] = charges) do
    Repo.preload(charges, [:card, :token])
  end

  defp preload_source(arg), do: arg
end
