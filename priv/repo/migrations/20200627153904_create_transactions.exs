defmodule Exchanger.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :from_amount, :integer
      add :from_currency, :string
      add :type, :string
      add :to_amount, :integer
      add :to_currency, :string
      add :exchange_rate, :float
      add :from_user_id, references(:users, on_delete: :nothing)
      add :from_wallet_id, references(:wallets, on_delete: :nothing)
      add :to_user_id, references(:users, on_delete: :nothing)
      add :to_wallet_id, references(:wallets, on_delete: :nothing)

      timestamps()
    end

    create index(:transactions, [:from_user_id])
    create index(:transactions, [:from_wallet_id])
    create index(:transactions, [:to_user_id])
    create index(:transactions, [:to_wallet_id])
  end
end
