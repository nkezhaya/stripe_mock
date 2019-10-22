defmodule StripeMock.API.Token do
  use StripeMock.Schema

  schema "tokens" do
    field :client_ip, :string
    field :type, :string
    field :used, :boolean, default: false

    belongs_to :card, API.Card

    common_fields()
    timestamps()
  end

  @doc false
  def changeset(token, attrs) do
    token
    |> cast(attrs, [:client_ip, :type])
    |> cast_assoc(:card, with: &API.Card.token_changeset/2)
    |> set_type()
    |> validate_required([:client_ip, :type])
    |> put_common_fields()
  end

  defp set_type(changeset) do
    case get_field(changeset, :card) do
      nil -> changeset
      _ -> put_change(changeset, :type, "card")
    end
  end
end
