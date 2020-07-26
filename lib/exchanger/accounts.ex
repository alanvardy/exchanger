defmodule Exchanger.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Exchanger.Repo
  alias Exchanger.Accounts.{Transaction, User, Wallet}

  @type success_tuple(struct) :: {:ok, struct} | {:error, Ecto.Changeset.t()}
  @type user :: User.t()
  @type wallet :: Wallet.t()
  @type transaction :: Transaction.t()
  @type changeset :: Ecto.Changeset.t()
  @type id :: pos_integer
  @type amount :: pos_integer
  @type currency :: String.t()

  @spec list_users :: [user]
  def list_users do
    Repo.all(User)
  end

  @spec get_user!(id) :: user
  def get_user!(id), do: Repo.get!(User, id)

  @spec create_user(map) :: success_tuple(user)
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_user(user, map) :: success_tuple(user)
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @spec delete_user(user) :: success_tuple(user)
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @spec change_user(user, map) :: changeset
  @spec change_user(user) :: changeset
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  @spec list_wallets :: [wallet]
  def list_wallets do
    Repo.all(Wallet)
  end

  @spec get_wallet!(id) :: wallet
  def get_wallet!(id), do: Repo.get!(Wallet, id)

  @spec create_wallet(map) :: success_tuple(wallet)
  def create_wallet(attrs) do
    attrs
    |> Wallet.create_changeset()
    |> Repo.insert()
  end

  @spec list_transactions :: [transaction]
  def list_transactions do
    Repo.all(Transaction)
  end

  @spec get_transaction!(id) :: transaction
  def get_transaction!(id), do: Repo.get!(Transaction, id)

  @spec create_deposit(wallet, currency, amount) :: success_tuple(transaction)
  def create_deposit(%Wallet{} = wallet, currency, amount) do
    wallet
    |> Transaction.create_deposit_changeset(currency, amount)
    |> Repo.insert()
  end
end
