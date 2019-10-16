defmodule StripeMock.API.Operations.Token do
  import Ecto.Query

  alias Ecto.Multi
  alias StripeMock.Repo
  alias StripeMock.API.{Token, PaymentMethod}

  def get_token(id) do
    Token
    |> preload(:card)
    |> Repo.fetch(id)
  end

  def create_token(attrs) do
    Multi.new()
    |> Multi.insert(:token, Token.changeset(%Token{}, attrs))
    |> Multi.run(:payment_method, fn _repo, %{token: token} ->
      %PaymentMethod{}
      |> PaymentMethod.changeset(%{token_id: token.id})
      |> Repo.insert()
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{token: token}} -> {:ok, token}
      {:error, _, value, _} -> {:error, value}
    end
  end
end
