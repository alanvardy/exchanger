defmodule Exchanger.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Exchanger.Repo
  alias Exchanger.Accounts.{Transaction, User, Wallet}

  @type id :: pos_integer
  @type success_tuple(struct) :: {:ok, struct} | {:error, Ecto.Changeset.t()}

  @spec list_users :: [User.t()]
  def list_users do
    Repo.all(User)
  end

  @spec get_user!(id) :: User.t()
  def get_user!(id), do: Repo.get!(User, id)

  @spec create_user(map) :: success_tuple(User.t())
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_user(User.t(), map) :: success_tuple(User.t())
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @spec delete_user(User.t()) :: success_tuple(User.t())
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @spec change_user(User.t(), map) :: Ecto.Changeset.t()
  @spec change_user(User.t()) :: Ecto.Changeset.t()
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  @spec list_wallets :: [Wallet.t()]
  def list_wallets do
    Repo.all(Wallet)
  end

  @spec get_wallet!(any) :: Wallet.t()
  def get_wallet!(id), do: Repo.get!(Wallet, id)

  @spec create_wallet(map) :: success_tuple(Wallet.t())
  def create_wallet(attrs) do
    attrs
    |> Wallet.create_changeset()
    |> Repo.insert()
  end

  @spec list_transactions :: [Transaction.t()]
  def list_transactions do
    Repo.all(Transaction)
  end

  @spec get_transaction!(any) :: Transaction.t()
  def get_transaction!(id), do: Repo.get!(Transaction, id)

  @spec create_transaction(map) :: success_tuple(Transaction.t())
  def create_transaction(attrs) do
    attrs
    |> Transaction.create_changeset()
    |> Repo.insert()
  end
end
