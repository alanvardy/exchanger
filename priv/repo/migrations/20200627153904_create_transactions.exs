defmodule Exchanger.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def up do
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

    execute("""
    CREATE FUNCTION aggregate_wallet_balance() RETURNS TRIGGER AS $$
    BEGIN

    UPDATE wallets
    SET balance = balance - NEW.from_amount
    WHERE id = NEW.from_wallet_id;

    UPDATE wallets
    SET balance = balance + NEW.to_amount
    WHERE id = NEW.to_wallet_id;

    RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;
    """)

    execute("""
    CREATE TRIGGER aggregate_trigger AFTER
    INSERT on transactions
    FOR EACH ROW EXECUTE PROCEDURE aggregate_wallet_balance();
    """)
  end

  def down do
    drop table(:transactions)
    execute("DROP FUNCTION aggregate_wallet_balance;")
  end
end
