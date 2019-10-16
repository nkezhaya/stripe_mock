defmodule StripeMock.API.Operations.Token do
  import Ecto.Query

  alias Ecto.Multi
  alias StripeMock.Repo
  alias StripeMock.API.{Token, Source}

  def get_token(id) do
    Token
    |> preload(:card)
    |> Repo.fetch(id)
  end

  def create_token(attrs) do
    Multi.new()
    |> Multi.insert(:token, Token.changeset(%Token{}, attrs))
    |> Multi.run(:source, fn _repo, %{token: token} ->
      %Source{}
      |> Source.changeset(%{token_id: token.id})
      |> Repo.insert()
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{token: token}} -> {:ok, token}
      {:error, _, value, _} -> {:error, value}
    end
  end
end
