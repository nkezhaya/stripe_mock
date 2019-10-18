defmodule StripeMock.Repo.Migrations.CreateTables do
  use Ecto.Migration

  defmacro common_fields() do
    quote do
      add(:id, :string, null: false, primary_key: true)
      add(:deleted, :boolean, null: false, default: false)
      add(:description, :string, null: true)
      add(:metadata, :map, null: false, default: %{})
      timestamps(inserted_at: :created, updated_at: false)
    end
  end

  def change do
    create table(:customers, primary_key: false) do
      add(:currency, :string, default: "usd")
      add(:email, :string)
      add(:name, :string)
      add(:phone, :string)

      common_fields()
    end

    create table(:cards, primary_key: false) do
      add(:brand, :string)
      add(:last4, :string)
      add(:source, :string)

      add(:number, :string)
      add(:exp_month, :integer)
      add(:exp_year, :integer)
      add(:cvc, :string)

      add(:customer_id, references(:customers))

      common_fields()
    end

    create table(:tokens, primary_key: false) do
      add(:client_ip, :string)
      add(:type, :string)
      add(:used, :boolean, default: false)

      add(:card_id, references(:cards))

      common_fields()
    end

    create table(:sources, primary_key: false) do
      common_fields()
    end

    create table(:payment_methods, primary_key: false) do
      add(:card_id, references(:cards))
      add(:token_id, references(:tokens))
      add(:source_id, references(:sources))

      common_fields()
    end

    create table(:payment_intents, primary_key: false) do
      add(:amount, :integer)
      add(:capture_method, :string)
      add(:confirmation_method, :string)
      add(:currency, :string)
      add(:payment_method_types, {:array, :string}, default: ["card"])
      add(:statement_descriptor, :string)
      add(:status, :string)
      add(:transfer_data, :map)
      add(:transfer_group, :string)

      add(:customer_id, references(:customers))
      add(:payment_method_id, references(:payment_methods))

      common_fields()
    end

    create table(:charges, primary_key: false) do
      add(:amount, :integer)
      add(:captured, :boolean, default: false)
      add(:currency, :string)
      add(:statement_descriptor, :string)
      add(:transfer_group, :string)

      add(:customer_id, references(:customers))
      add(:card_id, references(:cards))
      add(:token_id, references(:tokens))
      add(:payment_intent_id, references(:payment_intents))

      common_fields()
    end

    create table(:refunds, primary_key: false) do
      add(:amount, :integer)
      add(:reason, :string)

      add(:charge_id, references(:charges))

      common_fields()
    end
  end
end
