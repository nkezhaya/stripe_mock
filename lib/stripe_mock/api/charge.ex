defmodule StripeMock.API.Charge do
  use StripeMock.Schema
  alias StripeMock.Repo

  @foreign_key_type :binary_id
  schema "charges" do
    field :amount, :integer
    field :capture, :boolean, default: false
    field :currency, :string
    field :description, :string
    field :metadata, StripeMock.Type.Metadata, default: %{}
    field :statement_descriptor, :string
    field :transfer_group, :string

    belongs_to :customer, API.Customer
    belongs_to :source, API.Card
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
      :source_id,
      :statement_descriptor,
      :transfer_group
    ])
    |> validate_required([:amount, :currency])
    |> set_customer_and_source()
    |> validate_required(:source_id)
  end

  @doc false
  def update_changeset(charge, attrs) do
    charge
    |> cast(attrs, [
      :customer_id,
      :description,
      :metadata,
      :transfer_group
    ])
    |> validate_required([:amount, :currency])
  end

  @doc false
  def capture_changeset(payment_intent, charge) do
  end

  defp set_customer_and_source(changeset) do
    customer =
      with customer_id when not is_nil(customer_id) <- get_field(changeset, :customer_id) do
        case Repo.fetch(API.Customer, customer_id) do
          {:ok, customer} -> customer
          _ -> throw({:not_found, :customer_id})
        end
      else
        _ -> nil
      end

    source =
      case fetch_source(get_field(changeset, :source_id)) do
        :invalid -> throw({:not_found, :source_id})
        source -> source
      end

    case {get_field(changeset, :customer_id), get_field(changeset, :source_id)} do
      {nil, nil} ->
        validate_required(changeset, :source_id)

      {nil, _source_id} ->
        case source do
          %{card: %{customer_id: nil}} -> changeset
          _ -> validate_required(changeset, :customer_id)
        end

      {customer_id, nil} ->
        # TODO: Get the default payment method.
        API.Card
        |> Repo.all()
        |> Enum.filter(&(&1.customer_id == customer_id))
        |> case do
          [source | _] -> put_change(changeset, :source_id, source.id)
          [] -> throw({:not_found, :source_id})
        end

      {nil, "card_" <> _} ->
        throw({:not_found, :source_id})

      {_customer_id, "card_" <> _} ->
        if source.customer_id != customer.id do
          throw({:not_found, :source_id})
        else
          changeset
        end

      {_customer_id, "tok_" <> _} ->
        changeset

      _ ->
        add_error(changeset, :base, "either source or customer is required")
    end
    |> ensure_source()
  catch
    {:not_found, field} -> add_error(changeset, field, "not found")
  end

  defp ensure_source(changeset) do
    with source when is_map(source) <- fetch_source(get_field(changeset, :source_id)) do
      changeset
    else
      _ -> add_error(changeset, :source, "is invalid")
    end
  end

  defp fetch_source("tok_" <> _ = token_id), do: Repo.get(API.Token, token_id)
  defp fetch_source("card_" <> _ = card_id), do: Repo.get(API.Card, card_id)
  defp fetch_source(nil), do: nil
  defp fetch_source(_), do: :invalid
end
