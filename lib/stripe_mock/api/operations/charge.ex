defmodule StripeMock.API.Operations.Charge do
  alias StripeMock.Repo
  alias StripeMock.API.{Card, Charge, Token}

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

  defp preload_source(charges) when is_list(charges) do
    Enum.map(charges, &preload_source/1)
  end

  defp preload_source({:ok, charge}) do
    {:ok, preload_source(charge)}
  end

  defp preload_source(%Charge{} = charge) do
    %{charge | source: fetch_source(charge.source_id)}
  end

  defp preload_source(any), do: any

  def create_charge(attrs \\ %{}) do
    %Charge{}
    |> Charge.create_changeset(attrs)
    |> Repo.insert()
    |> preload_source()
  end

  def update_charge(%Charge{} = charge, attrs) do
    charge
    |> Charge.create_changeset(attrs)
    |> Repo.update()
    |> preload_source()
  end

  defp fetch_source("card_" <> _ = card_id), do: Repo.get(Card, card_id)

  defp fetch_source("tok_" <> _ = token_id) do
    case Repo.get(Token, token_id) do
      %{card_id: card_id} -> fetch_source(card_id)
      _ -> nil
    end
  end

  defp fetch_source(nil), do: nil
end
