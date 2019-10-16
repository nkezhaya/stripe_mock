defmodule StripeMock.Repo.Migrations.CreateTables do
  use Ecto.Migration

  defmacro common_fields() do
    quote do
      add(:deleted, :boolean, null: false, default: false)
      add(:description, :string)
      add(:metadata, :map, null: false, default: %{})
      timestamps(inserted_at: :created, updated_at: false)
    end
  end

  def change do
    create table(:customers) do
      add(:currency, :string, default: "usd")
      add(:email, :string)
      add(:name, :string)
      add(:phone, :string)

      common_fields()
    end

    create table(:cards) do
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

    create table(:tokens) do
      add(:client_ip, :string)
      add(:type, :string)
      add(:used, :boolean, default: false)

      add(:card_id, references(:cards))

      common_fields()
    end

    create table(:sources) do
      add(:card_id, references(:cards))
      add(:token_id, references(:tokens))
    end

    create table(:charges) do
      add(:amount, :integer)
      add(:capture, :boolean, default: false)
      add(:currency, :string)
      add(:statement_descriptor, :string)
      add(:transfer_group, :string)

      add(:customer_id, references(:customers))
      add(:card_id, references(:cards))
      add(:token_id, references(:tokens))

      common_fields()
    end

    create table(:refunds) do
      add(:amount, :integer)
      add(:reason, :string)

      add(:charge_id, references(:charges))

      common_fields()
    end
  end
end
