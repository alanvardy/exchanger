defmodule Exchanger.AccountsTest do
  use Exchanger.DataCase

  alias Exchanger.Accounts

  describe "users" do
    alias Exchanger.Accounts.User

    @valid_attrs %{first_name: "some first_name", last_name: "some last_name"}
    @update_attrs %{first_name: "some updated first_name", last_name: "some updated last_name"}
    @invalid_attrs %{first_name: nil, last_name: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.first_name == "some first_name"
      assert user.last_name == "some last_name"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.first_name == "some updated first_name"
      assert user.last_name == "some updated last_name"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "wallets" do
    alias Exchanger.Accounts.Wallet

    @valid_attrs %{currency: "some currency", user_id: 1}
    @update_attrs %{currency: "some updated currency", user_id: 2}
    @invalid_attrs %{currency: nil}

    def wallet_fixture(attrs \\ %{}) do
      user_id = Enum.random(1..1000)

      {:ok, wallet} =
        attrs
        |> Map.merge(%{user_id: user_id})
        |> Enum.into(@valid_attrs)
        |> Accounts.create_wallet()

      wallet
    end

    test "list_wallets/0 returns all wallets" do
      wallet = wallet_fixture()
      assert Accounts.list_wallets() == [wallet]
    end

    test "get_wallet!/1 returns the wallet with given id" do
      wallet = wallet_fixture()
      assert Accounts.get_wallet!(wallet.id) == wallet
    end

    test "create_wallet/1 with valid data creates a wallet" do
      assert {:ok, %Wallet{} = wallet} = Accounts.create_wallet(@valid_attrs)
      assert wallet.currency == "some currency"
    end

    test "create_wallet/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_wallet(@invalid_attrs)
    end
  end

  describe "transactions" do
    alias Exchanger.Accounts.Transaction

    @valid_attrs %{
      exchange_rate: 120.5,
      from_amount: 42,
      from_currency: "some from_currency",
      to_amount: 42,
      to_currency: "some to_currency",
      from_user_id: 1,
      to_user_id: 2,
      from_wallet_id: 3,
      to_wallet_id: 4
    }
    @update_attrs %{
      exchange_rate: 456.7,
      from_amount: 43,
      from_currency: "some updated from_currency",
      to_amount: 43,
      to_currency: "some updated to_currency"
    }
    @invalid_attrs %{
      exchange_rate: nil,
      from_amount: nil,
      from_currency: nil,
      to_amount: nil,
      to_currency: nil
    }

    def transaction_fixture(attrs \\ %{}) do
      ids = %{
        from_user_id: Enum.random(1..1000),
        to_user_id: Enum.random(1..1000),
        from_wallet_id: Enum.random(1..1000),
        to_wallet_id: Enum.random(1..1000)
      }

      {:ok, transaction} =
        attrs
        |> Map.merge(ids)
        |> Enum.into(@valid_attrs)
        |> Accounts.create_transaction()

      transaction
    end

    test "list_transactions/0 returns all transactions" do
      transaction = transaction_fixture()
      assert Accounts.list_transactions() == [transaction]
    end

    test "get_transaction!/1 returns the transaction with given id" do
      transaction = transaction_fixture()
      assert Accounts.get_transaction!(transaction.id) == transaction
    end

    test "create_transaction/1 with valid data creates a transaction" do
      assert {:ok, %Transaction{} = transaction} = Accounts.create_transaction(@valid_attrs)
      assert transaction.exchange_rate == 120.5
      assert transaction.from_amount == 42
      assert transaction.from_currency == "some from_currency"
      assert transaction.to_amount == 42
      assert transaction.to_currency == "some to_currency"
    end

    test "create_transaction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_transaction(@invalid_attrs)
    end
  end
end
