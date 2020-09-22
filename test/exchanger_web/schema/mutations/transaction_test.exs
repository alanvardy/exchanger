defmodule ExchangerWeb.Schema.Mutations.TransactionTest do
  use Exchanger.DataCase, async: true
  alias Exchanger.Accounts
  alias Exchanger.Accounts.Balance

  @create_deposit_doc """
    mutation createDeposit($to_user_id: ID, $to_amount: Int, $to_currency: String) {
      create_deposit(to_user_id: $to_user_id, to_amount: $to_amount, to_currency: $to_currency) {
        id
      }
    }
  """

  describe "@create_deposit" do
    test "creates a deposit" do
      user = insert(:user)
      wallet = insert(:wallet, user: user)

      assert %{data: %{"create_deposit" => %{"id" => _}}} =
               run_schema(@create_deposit_doc, %{
                 "to_currency" => wallet.currency,
                 "to_user_id" => user.id,
                 "to_amount" => 10_000
               })

      {:ok, transactions} = Accounts.all_transactions(%{})
      assert Enum.count(transactions) == 1

      assert {:ok, %Balance{amount: 10_000}} =
               Accounts.fetch_user_balance(user.id, wallet.currency)
    end

    test "won't create a deposit in a currency where the user does not have a wallet" do
      user = insert(:user)
      wallet = insert(:wallet, user: user, currency: "USD")

      assert %{errors: [%{message: "Wallet not found for currency"}]} =
               run_schema(@create_deposit_doc, %{
                 "to_currency" => "CAD",
                 "to_user_id" => user.id,
                 "to_amount" => 10_000
               })

      {:ok, transactions} = Accounts.all_transactions(%{})
      assert Enum.empty?(transactions)

      assert {:ok, %Balance{amount: 0}} = Accounts.fetch_user_balance(user.id, wallet.currency)
    end
  end

  @create_withdrawal_doc """
    mutation createWithdrawal($from_user_id: ID, $from_amount: Int, $from_currency: String) {
      create_withdrawal(from_user_id: $from_user_id, from_amount: $from_amount, from_currency: $from_currency) {
        id
      }
    }
  """

  describe "@create_withdrawal" do
    test "creates a withdrawal" do
      currency = "USD"
      user = insert(:user)
      from_wallet = insert(:wallet, user: user, currency: currency)

      assert {:ok, _} =
               Accounts.create_deposit(%{
                 to_user_id: from_wallet.user_id,
                 to_amount: 10_000,
                 to_currency: currency
               })

      assert {:ok, %Balance{amount: 10_000}} = Accounts.fetch_user_balance(user.id, currency)

      assert %{data: %{"create_withdrawal" => %{"id" => _}}} =
               run_schema(@create_withdrawal_doc, %{
                 "from_currency" => currency,
                 "from_user_id" => from_wallet.user_id,
                 "from_amount" => 5_000
               })

      {:ok, transactions} = Accounts.all_transactions(%{})
      assert Enum.count(transactions) == 2

      assert {:ok, %Balance{amount: 5_000}} = Accounts.fetch_user_balance(user.id, currency)
    end

    test "won't create a withdrawal in a currency where the user does not have a wallet" do
      user = insert(:user)
      from_wallet = insert(:wallet, user: user, currency: "USD")

      assert {:ok, _} =
               Accounts.create_deposit(%{
                 to_user_id: from_wallet.user_id,
                 to_amount: 10_000,
                 to_currency: from_wallet.currency
               })

      assert %{errors: [%{message: "Wallet not found for currency"}]} =
               run_schema(@create_withdrawal_doc, %{
                 "from_currency" => "CAD",
                 "from_user_id" => user.id,
                 "from_amount" => 5_000
               })

      {:ok, transactions} = Accounts.all_transactions(%{})
      assert Enum.count(transactions) == 1

      assert {:ok, %Balance{amount: 10_000}} =
               Accounts.fetch_user_balance(user.id, from_wallet.currency)
    end

    test "will not overdraw wallet" do
      user = insert(:user)
      from_wallet = insert(:wallet, user: user, currency: "USD")

      assert {:ok, _} =
               Accounts.create_deposit(%{
                 to_user_id: from_wallet.user_id,
                 to_amount: 10_000,
                 to_currency: from_wallet.currency
               })

      assert %{errors: [%{message: "Insufficient funds"}]} =
               run_schema(@create_withdrawal_doc, %{
                 "from_currency" => from_wallet.currency,
                 "from_user_id" => user.id,
                 "from_amount" => 20_000
               })

      {:ok, transactions} = Accounts.all_transactions(%{})
      assert Enum.count(transactions) == 1

      assert {:ok, %Balance{amount: 10_000}} =
               Accounts.fetch_user_balance(user.id, from_wallet.currency)
    end
  end

  @create_transfer_doc """
    mutation createTransfer($to_user_id: ID, $to_amount: Int, $to_currency: String, $from_wallet_id: ID) {
      create_transfer(to_user_id: $to_user_id, to_amount: $to_amount, to_currency: $to_currency, from_wallet_id: $from_wallet_id) {
        id
      }
    }
  """

  describe "@create_transfer" do
    test "creates a transfer" do
      currency = "USD"
      from_wallet = insert(:wallet, user: build(:user), currency: currency)

      assert {:ok, _} =
               Accounts.create_deposit(%{
                 to_user_id: from_wallet.user_id,
                 to_amount: 10_000,
                 to_currency: currency
               })

      to_wallet = insert(:wallet, user: build(:user))

      assert {:ok, %Balance{amount: 10_000}} =
               Accounts.fetch_user_balance(from_wallet.user_id, currency)

      assert {:ok, %Balance{amount: 0}} = Accounts.fetch_user_balance(to_wallet.user_id, currency)

      assert %{data: %{"create_transfer" => %{"id" => _}}} =
               run_schema(@create_transfer_doc, %{
                 "to_user_id" => to_wallet.user_id,
                 "to_currency" => currency,
                 "to_amount" => 6_000,
                 "from_wallet_id" => from_wallet.id
               })

      {:ok, transactions} = Accounts.all_transactions(%{})
      assert Enum.count(transactions) == 2

      assert {:ok, %Balance{amount: 4_000}} =
               Accounts.fetch_user_balance(from_wallet.user_id, currency)

      assert {:ok, %Balance{amount: 6_000}} =
               Accounts.fetch_user_balance(to_wallet.user_id, currency)
    end

    test "can transfer across currencies" do
      from_wallet = insert(:wallet, user: build(:user), currency: "CAD")

      assert {:ok, _} =
               Accounts.create_deposit(%{
                 to_user_id: from_wallet.user_id,
                 to_amount: 10_000,
                 to_currency: "CAD"
               })

      to_wallet = insert(:wallet, user: build(:user), currency: "USD")

      assert {:ok, %Balance{amount: 10_000}} =
               Accounts.fetch_user_balance(from_wallet.user_id, "CAD")

      assert {:ok, %Balance{amount: 0}} = Accounts.fetch_user_balance(to_wallet.user_id, "USD")

      assert %{data: %{"create_transfer" => %{"id" => _}}} =
               run_schema(@create_transfer_doc, %{
                 "to_user_id" => to_wallet.user_id,
                 "to_currency" => "USD",
                 "to_amount" => 6_000,
                 "from_wallet_id" => from_wallet.id
               })

      {:ok, transactions} = Accounts.all_transactions(%{})
      assert Enum.count(transactions) == 2

      assert {:ok, %Balance{amount: 2_000}} =
               Accounts.fetch_user_balance(from_wallet.user_id, "CAD")

      assert {:ok, %Balance{amount: 6_000}} =
               Accounts.fetch_user_balance(to_wallet.user_id, "USD")
    end

    test "cannot transfer if insufficient funds" do
      currency = "USD"
      from_wallet = insert(:wallet, user: build(:user), currency: currency)

      assert {:ok, _} =
               Accounts.create_deposit(%{
                 to_user_id: from_wallet.user_id,
                 to_amount: 5_000,
                 to_currency: currency
               })

      to_wallet = insert(:wallet, user: build(:user), currency: "USD")

      assert {:ok, %Balance{amount: 5_000}} =
               Accounts.fetch_user_balance(from_wallet.user_id, currency)

      assert {:ok, %Balance{amount: 0}} = Accounts.fetch_user_balance(to_wallet.user_id, currency)

      assert %{errors: [%{message: "Insufficient funds"}]} =
               run_schema(@create_transfer_doc, %{
                 "to_user_id" => to_wallet.user_id,
                 "to_currency" => currency,
                 "to_amount" => 6_000,
                 "from_wallet_id" => from_wallet.id
               })

      {:ok, transactions} = Accounts.all_transactions(%{})
      assert Enum.count(transactions) == 1

      assert {:ok, %Balance{amount: 5_000}} =
               Accounts.fetch_user_balance(from_wallet.user_id, currency)

      assert {:ok, %Balance{amount: 0}} = Accounts.fetch_user_balance(to_wallet.user_id, currency)
    end
  end
end
