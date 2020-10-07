defmodule ExchangerWeb.GraphQL.Queries.TransactionTest do
  use Exchanger.DataCase, async: true

  @transaction_doc """
    query getTransaction($id: ID) {
      transaction(id: $id) {
        id
        inserted_at
        type
      }
    }
  """

  @transactions_doc """
    query allTransactions($from_wallet_id: ID, $type: String) {
      transactions(from_wallet_id: $from_wallet_id, type: $type) {
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
        |> get_in([:data, "transaction", "id"])

      assert transaction_id === Integer.to_string(id)
    end

    test "Can get the inserted_at datetime", %{transaction: %{id: id, inserted_at: inserted_at}} do
      timestamp =
        @transaction_doc
        |> run_schema(%{"id" => id})
        |> get_in([:data, "transaction", "inserted_at"])

      assert timestamp === DateTime.to_iso8601(inserted_at)
    end

    test "Can get the transaction type", %{transaction: %{id: id, type: transaction_type}} do
      type =
        @transaction_doc
        |> run_schema(%{"id" => id})
        |> get_in([:data, "transaction", "type"])

      assert type === String.upcase(transaction_type)
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
        |> get_in([:data, "transactions"])

      transaction_id = Integer.to_string(transaction_id)

      assert [%{"id" => ^transaction_id}] = transactions
    end

    test "Can get transactions by from_wallet_id and type", %{
      transaction: %{id: transaction_id, type: type},
      from_wallet: %{id: from_wallet_id}
    } do
      transactions =
        @transactions_doc
        |> run_schema(%{"from_wallet_id" => from_wallet_id, "type" => type})
        |> get_in([:data, "transactions"])

      transaction_id = Integer.to_string(transaction_id)

      assert [%{"id" => ^transaction_id}] = transactions
    end

    @transactions_doc """
      query allTransactions($start_date: String) {
        transactions(start_date: $start_date) {
          id
        }
      }
    """

    test "gets a transaction inserted_at before datetime", %{transaction: %{id: transaction_id}} do
      now = DateTime.utc_now() |> DateTime.add(-5, :second) |> DateTime.to_iso8601()

      transactions =
        @transactions_doc
        |> run_schema(%{"start_date" => now})
        |> get_in([:data, "transactions"])

      transaction_id = Integer.to_string(transaction_id)

      assert [%{"id" => ^transaction_id}] = transactions
    end

    test "doesnt get transaction inserted_at after datetime" do
      now = DateTime.utc_now() |> DateTime.add(5, :second) |> DateTime.to_iso8601()

      transactions =
        @transactions_doc
        |> run_schema(%{"start_date" => now})
        |> get_in([:data, "transactions"])

      assert Enum.empty?(transactions)
    end
  end
end
