defmodule ExchangerWeb.Schema.Queries.TransactionTest do
  use Exchanger.DataCase, async: true

  @transaction_doc """
    query getTransaction($id: ID) {
      transaction(id: $id) {
        id
        inserted_at
      }
    }
  """

  @transactions_doc """
    query allTransactions($from_wallet_id: ID) {
      transactions(from_wallet_id: $from_wallet_id) {
        id
      }
    }
  """

  setup do
    from_user = insert(:user)
    from_wallet = insert(:wallet, user: from_user)
    to_user = insert(:user)
    to_wallet = insert(:wallet, user: to_user)

    transaction =
      insert(:transfer,
        from_user: from_user,
        from_wallet: from_wallet,
        from_currency: from_wallet.currency,
        to_user: to_user,
        to_wallet: to_wallet,
        to_currency: to_wallet.currency
      )

    %{
      from_user: from_user,
      to_user: to_user,
      from_wallet: from_wallet,
      to_wallet: to_wallet,
      transaction: transaction
    }
  end

  describe "@transaction" do
    test "Can get a transaction by id", %{transaction: %{id: id}} do
      transaction_id =
        @transaction_doc
        |> run_schema(%{"id" => id})
        |> get_in(["transaction", "id"])

      assert transaction_id === Integer.to_string(id)
    end

    test "Can get the inserted_at datetime", %{transaction: %{id: id, inserted_at: inserted_at}} do
      timestamp =
        @transaction_doc
        |> run_schema(%{"id" => id})
        |> get_in(["transaction", "inserted_at"])

      assert timestamp === DateTime.to_iso8601(inserted_at)
    end
  end

  describe "@transactions" do
    test "Can get transactions by from_wallet_id", %{
      transaction: %{id: transaction_id},
      from_wallet: %{id: from_wallet_id}
    } do
      transactions =
        @transactions_doc
        |> run_schema(%{"from_wallet_id" => from_wallet_id})
        |> get_in(["transactions"])

      transaction_id = Integer.to_string(transaction_id)

      assert [%{"id" => ^transaction_id}] = transactions
    end
  end
end
