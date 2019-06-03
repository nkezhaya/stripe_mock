defmodule StripeMock.API.Operations.Token do
  alias StripeMock.Repo
  alias StripeMock.API.Token

  def get_token(id) do
    Repo.fetch(Token, id)
  end

  def create_token(attrs) do
    %Token{}
    |> Token.changeset(attrs)
    |> Repo.insert()
  end
end
