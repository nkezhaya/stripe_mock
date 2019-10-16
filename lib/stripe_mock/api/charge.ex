defmodule StripeMock.API.Charge do
  use StripeMock.Schema

  schema "charges" do
    field :amount, :integer
    field :capture, :boolean, default: false
    field :currency, :string
    field :description, :string
    field :metadata, :map, default: %{}
    field :statement_descriptor, :string
    field :transfer_group, :string

    field :source, :string, virtual: true

    belongs_to :customer, API.Customer
    belongs_to :card, API.Card
    belongs_to :token, API.Token

    timestamps()
  end

  @doc false
  def create_changeset(charge, attrs) do
    charge
    |> cast(attrs, [
      :amount,
      :currency,
      :capture,
      :customer_id,
      :description,
      :metadata,
      :source,
      :statement_descriptor,
      :transfer_group
    ])
    |> set_customer_and_source()
    |> validate_required([:amount, :currency, :card_id])
    |> put_common_fields()
  end

  @doc false
  def update_changeset(charge, attrs) do
    charge
    |> cast(attrs, [
      :description,
      :metadata,
      :transfer_group
    ])
    |> put_common_fields()
  end

  defp set_customer_and_source(changeset) do
    source =
      case fetch_source(get_field(changeset, :source)) do
        nil -> throw({:not_found, :source})
        source -> source
      end

    case source do
      nil ->
        add_error(changeset, :base, "either source or customer is required")

      %API.Card{} ->
        changeset
        |> put_change(:card_id, source.id)
        |> validate_required(:customer_id)

      %API.Token{} ->
        changeset
        |> put_change(:token_id, source.id)
        |> put_change(:card_id, source.card_id)
    end
  catch
    {:not_found, field} -> add_error(changeset, field, "not found")
  end

  defp fetch_source(nil) do
    nil
  end

  defp fetch_source(source) do
    card = Repo.get(API.Card, source)
    token = Repo.get(API.Token, source)

    card || token
  end
end
