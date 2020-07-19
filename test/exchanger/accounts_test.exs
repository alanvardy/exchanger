defmodule Exchanger.AccountsTest do
  use Exchanger.DataCase

  alias Exchanger.Accounts

  describe "users" do
    alias Exchanger.Accounts.User

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
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(params_for(:user, first_name: nil))
    end

    test "update_user/2 with valid data updates the user" do
      user = insert(:user)
      params = params_for(:user)
      assert {:ok, %User{} = user} = Accounts.update_user(user, params)
      assert user.first_name == params.first_name
      assert user.last_name == params.last_name
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = insert(:user)
      params = params_for(:user, first_name: "")
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, params)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = insert(:user)
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = insert(:user)
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "wallets" do
    alias Exchanger.Accounts.Wallet

    test "list_wallets/0 returns all wallets" do
      wallet = insert(:wallet)
      assert_comparable(Accounts.list_wallets(), [wallet])
    end

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
      assert {:error, %Ecto.Changeset{}} = Accounts.create_wallet(params_for(:wallet, currency: nil))
    end
  end

  describe "transactions" do
    alias Exchanger.Accounts.Transaction

    test "list_transactions/0 returns all transactions" do
      transaction = insert(:transaction)
      assert_comparable(Accounts.list_transactions(), [transaction])
    end

    test "get_transaction!/1 returns the transaction with given id" do
      transaction = insert(:transaction)
      assert_comparable(Accounts.get_transaction!(transaction.id), transaction)
    end

    test "create_transaction/1 with valid data creates a transaction" do
      from_wallet = insert(:wallet)
      to_wallet = insert(:wallet)
      params = params_for(:transaction, from_wallet: from_wallet, from_user: from_wallet.user, to_wallet: to_wallet, to_user: to_wallet.user)
      assert {:ok, %Transaction{} = transaction} = Accounts.create_transaction(params)
      assert_comparable(params, transaction)
    end

    test "create_transaction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_transaction(params_for(:transaction, from_currency: nil))
    end
  end
end
