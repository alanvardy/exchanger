defmodule Exchanger.AccountsTest do
  use Exchanger.DataCase

  alias Exchanger.Accounts
  alias Exchanger.Accounts.{Balance, Transaction, User, Wallet}

  @currencies Application.get_env(:exchanger, :currencies)

  setup_all do
    start_supervised({Exchanger.ExchangeRate.Store, @currencies})
    start_supervised({Exchanger.ExchangeRate.Updater, @currencies})

    # Give the Updater time to update Store
    :timer.sleep(100)
    :ok
  end

  describe "users" do
    test "list_users/0 returns all users" do
      user = insert(:user)
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = insert(:user)
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      params = params_for(:user)
      assert {:ok, %User{} = user} = Accounts.create_user(params)
      assert user.first_name == params.first_name
      assert user.last_name == params.last_name
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_user(params_for(:user, first_name: nil))
    end
  end

  describe "wallets" do
    test "get_wallet!/1 returns the wallet with given id" do
      wallet = insert(:wallet)
      assert_comparable(Accounts.get_wallet!(wallet.id), wallet)
    end

    test "create_wallet/1 with valid data creates a wallet" do
      user = insert(:user)
      params = params_for(:wallet, user_id: user.id)
      assert {:ok, %Wallet{} = wallet} = Accounts.create_wallet(params)
      assert wallet.currency == params.currency
    end

    test "create_wallet/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_wallet(params_for(:wallet, currency: nil))
    end

    test "fetch_wallet_by_currency/2 with invalid data returns error changeset" do
      user = insert(:user)
      insert(:wallet, user: user, currency: "USD")
      insert(:wallet, user: user, currency: "CAD")

      assert {:ok, %Wallet{currency: "USD"}} = Accounts.fetch_wallet_by_currency(user, "USD")
      assert {:ok, %Wallet{currency: "CAD"}} = Accounts.fetch_wallet_by_currency(user, "CAD")
    end
  end

  describe "create_deposit/1" do
    test "with valid data creates a transaction" do
      wallet = insert(:wallet, user: build(:user))
      user_id = wallet.user_id
      wallet_id = wallet.id

      assert {:ok,
              %Transaction{
                type: "deposit",
                to_amount: 500,
                to_user_id: ^user_id,
                to_wallet_id: ^wallet_id,
                from_user_id: nil,
                from_wallet_id: nil
              }} =
               Accounts.create_deposit(%{
                 to_user_id: wallet.user_id,
                 to_currency: wallet.currency,
                 to_amount: 500
               })
    end

    test "with invalid data returns error changeset" do
      wallet = insert(:wallet, user: build(:user))

      assert {:error, "to_amount: can't be blank"} =
               Accounts.create_deposit(%{
                 to_user_id: wallet.user_id,
                 to_currency: wallet.currency,
                 to_amount: nil
               })

      assert {:error, "to_amount: must be less than or equal to 100000000"} =
               Accounts.create_deposit(%{
                 to_user_id: wallet.user_id,
                 to_currency: wallet.currency,
                 to_amount: 1_000_000_000
               })
    end
  end

  describe "create_transfer/3" do
    test "with valid data creates a transaction" do
      from_user = insert(:user)
      from_user_id = from_user.id
      from_wallet = insert(:wallet, user: from_user, currency: "USD")
      from_wallet_id = from_wallet.id
      to_user = insert(:user)
      to_user_id = to_user.id
      to_wallet = insert(:wallet, user: to_user, currency: "CAD")
      to_wallet_id = to_wallet.id

      assert {:ok, _} =
               Accounts.create_deposit(%{
                 to_user_id: from_wallet.user_id,
                 to_amount: 10_000,
                 to_currency: "USD"
               })

      assert {:ok,
              %Transaction{
                type: "transfer",
                from_amount: 746,
                to_amount: 1000,
                to_user_id: ^to_user_id,
                from_user_id: ^from_user_id,
                to_wallet_id: ^to_wallet_id,
                from_wallet_id: ^from_wallet_id,
                from_currency: "USD",
                to_currency: "CAD",
                exchange_rate: 1.34
              }} =
               Accounts.create_transfer(%{
                 from_wallet_id: from_wallet_id,
                 to_user_id: to_user.id,
                 to_currency: "CAD",
                 to_amount: 1000
               })

      assert %Wallet{balance: 1000, updated_at: updated_at} = Accounts.get_wallet!(to_wallet_id)
      assert %Wallet{balance: 9254} = Accounts.get_wallet!(from_wallet_id)
    end

    test "with same currencies creates a transaction" do
      from_user = insert(:user)
      from_user_id = from_user.id
      from_wallet = insert(:wallet, user: from_user, currency: "CAD")
      from_wallet_id = from_wallet.id

      assert {:ok, _} =
               Accounts.create_deposit(%{
                 to_user_id: from_wallet.user_id,
                 to_amount: 10_000,
                 to_currency: "CAD"
               })

      to_user = insert(:user)
      to_user_id = to_user.id
      to_wallet = insert(:wallet, user: to_user, currency: "CAD")
      to_wallet_id = to_wallet.id

      assert {:ok,
              %Transaction{
                type: "transfer",
                from_amount: 3000,
                to_amount: 3000,
                to_user_id: ^to_user_id,
                from_user_id: ^from_user_id,
                to_wallet_id: ^to_wallet_id,
                from_wallet_id: ^from_wallet_id,
                from_currency: "CAD",
                to_currency: "CAD",
                exchange_rate: 1.0
              }} =
               Accounts.create_transfer(%{
                 from_wallet_id: from_wallet_id,
                 to_user_id: to_user.id,
                 to_currency: "CAD",
                 to_amount: 3000
               })
    end
  end

  describe "get_wallet_balance!/1" do
    test "can get a balance with a deposit" do
      wallet = insert(:wallet, currency: "USD", user: build(:user))

      {:ok, %Transaction{}} =
        Accounts.create_deposit(%{
          to_user_id: wallet.user_id,
          to_currency: "USD",
          to_amount: 10_000
        })

      assert %Balance{amount: 10_000, currency: "USD"} = Accounts.get_wallet_balance!(wallet)
    end

    test "can get a balance with a deposit and transfers" do
      wallet1 = insert(:wallet, currency: "USD", user: build(:user))
      wallet2 = insert(:wallet, currency: "USD", user: build(:user))
      wallet3 = insert(:wallet, currency: "USD", user: build(:user))

      {:ok, %Transaction{}} =
        Accounts.create_deposit(%{
          to_user_id: wallet1.user_id,
          to_currency: "USD",
          to_amount: 10_000
        })

      {:ok, %Transaction{}} =
        Accounts.create_deposit(%{
          to_user_id: wallet3.user_id,
          to_currency: "USD",
          to_amount: 10_000
        })

      {:ok, %Transaction{}} =
        Accounts.create_transfer(%{
          from_wallet_id: wallet1.id,
          to_user_id: wallet2.user_id,
          to_currency: "USD",
          to_amount: 5_000
        })

      {:ok, %Transaction{}} =
        Accounts.create_transfer(%{
          from_wallet_id: wallet3.id,
          to_user_id: wallet1.user_id,
          to_currency: "USD",
          to_amount: 3_000
        })

      assert %Balance{amount: 8_000, currency: "USD"} = Accounts.get_wallet_balance!(wallet1)
      assert %Balance{amount: 5_000, currency: "USD"} = Accounts.get_wallet_balance!(wallet2)
      assert %Balance{amount: 7_000, currency: "USD"} = Accounts.get_wallet_balance!(wallet3)
    end
  end

  describe "fetch_user_balance/2" do
    test "Returns 0 for no wallets" do
      %User{id: user_id} = insert(:user)

      {:ok, %Balance{amount: 0}} = Accounts.fetch_user_balance(user_id, "USD")
    end

    test "Returns the balance of one wallet" do
      %User{id: user_id} = insert(:user)
      %Wallet{id: wallet_id} = insert(:wallet, currency: "USD", user_id: user_id)

      insert(:deposit,
        to_currency: "USD",
        to_amount: 20,
        to_wallet_id: wallet_id,
        to_user_id: user_id
      )

      {:ok, %Balance{amount: 20}} = Accounts.fetch_user_balance(user_id, "USD")
    end

    test "Can aggregate multiple wallets" do
      %User{id: user_id} = insert(:user)
      %Wallet{id: wallet_id} = insert(:wallet, currency: "USD", user_id: user_id)

      insert(:deposit,
        to_currency: "USD",
        to_amount: 20,
        to_wallet_id: wallet_id,
        to_user_id: user_id
      )

      insert(:deposit,
        to_currency: "USD",
        to_amount: 15,
        to_wallet_id: wallet_id,
        to_user_id: user_id
      )

      {:ok, %Balance{amount: 35}} = Accounts.fetch_user_balance(user_id, "USD")
    end

    test "Can aggregate multiple wallets with different currencies" do
      %User{id: user_id} = insert(:user)
      %Wallet{id: usd_id} = insert(:wallet, currency: "USD", user_id: user_id)
      %Wallet{id: cad_id} = insert(:wallet, currency: "CAD", user_id: user_id)

      insert(:deposit,
        to_currency: "USD",
        to_amount: 20,
        to_wallet_id: usd_id,
        to_user_id: user_id
      )

      insert(:deposit,
        to_currency: "CAD",
        to_amount: 20,
        to_wallet_id: cad_id,
        to_user_id: user_id
      )

      {:ok, %Balance{amount: 35, currency: "USD"}} = Accounts.fetch_user_balance(user_id, "USD")
      {:ok, %Balance{amount: 46, currency: "CAD"}} = Accounts.fetch_user_balance(user_id, "CAD")
    end
  end
end
