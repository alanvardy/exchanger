defmodule Exchanger.Accounts do
  @moduledoc """
  The Accounts context.
  """

  use Boundary, deps: [Exchanger, Exchanger.{ExchangeRate, Schema}]
  import Ecto.Query, warn: false
  alias Exchanger.{ExchangeRate, Repo}
  alias Exchanger.Accounts.{Transaction, User, Wallet}

  @type change_tuple(struct) :: {:ok, struct} | {:error, Ecto.Changeset.t()}
  @type user :: User.t()
  @type wallet :: Wallet.t()
  @type transaction :: Transaction.t()
  @type changeset :: Ecto.Changeset.t()
  @type id :: pos_integer
  @type amount :: pos_integer
  @type exchange_rate :: float
  @type currency :: String.t()

  # Users

  @spec list_users :: [user]
  def list_users do
    Repo.all(User)
  end

  @spec get_user!(id) :: user
  def get_user!(id), do: Repo.get!(User, id)

  @spec create_user(map) :: change_tuple(user)
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_user(user, map) :: change_tuple(user)
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @spec delete_user(user) :: change_tuple(user)
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  # Wallets

  @spec list_wallets :: [wallet]
  def list_wallets do
    Repo.all(Wallet)
  end

  def get_balance(%Wallet{id: id, currency: currency}) do
    with query <- id |> Wallet.where_id() |> Wallet.with_transactions(),
         %Wallet{sent_transactions: subs, received_transactions: adds} <- Repo.one(query),
         additions <- Enum.reduce(adds, 0, fn x, acc -> x.to_amount + acc end),
         subtractions <- Enum.reduce(subs, 0, fn x, acc -> x.from_amount + acc end) do
      {:ok, {additions - subtractions, currency}}
    else
      nil -> {:error, :wallet_not_found}
    end
  end

  @spec get_wallet!(id) :: wallet
  def get_wallet!(id), do: Repo.get!(Wallet, id)

  @spec fetch_wallet_by_currency(user, currency) :: {:ok, wallet} | {:error, :wallet_not_found}
  def fetch_wallet_by_currency(%User{id: user_id}, currency) do
    user_id
    |> Wallet.where_user_id()
    |> Wallet.where_currency(currency)
    |> Repo.one()
    |> case do
      nil -> {:error, :wallet_not_found}
      wallet -> {:ok, wallet}
    end
  end

  @spec create_wallet(map) :: change_tuple(wallet)
  def create_wallet(attrs) do
    attrs
    |> Wallet.create_changeset()
    |> Repo.insert()
  end

  # Transactions

  @spec list_transactions :: [transaction]
  def list_transactions do
    Repo.all(Transaction)
  end

  @spec get_transaction!(id) :: transaction
  def get_transaction!(id), do: Repo.get!(Transaction, id)

  @spec create_deposit(wallet, currency, amount) :: change_tuple(transaction)
  def create_deposit(%Wallet{} = wallet, currency, amount) do
    wallet
    |> Transaction.create_deposit_changeset(currency, amount)
    |> Repo.insert()
  end

  @spec create_transfer(wallet, wallet, amount) ::
          change_tuple(transaction) | {:error, :rate_not_found}
  def create_transfer(from_wallet, to_wallet, amount) do
    %Wallet{currency: from_currency} = from_wallet
    %Wallet{currency: to_currency} = to_wallet

    case ExchangeRate.fetch(from_currency, to_currency) do
      {:ok, %{rate: rate}} ->
        from_wallet
        |> Transaction.create_transfer_changeset(to_wallet, amount, rate)
        |> Repo.insert()

      error ->
        error
    end
  end
end
