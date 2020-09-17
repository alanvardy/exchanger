defmodule Exchanger.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias EctoShorts.Actions
  alias Exchanger.{ExchangeRate, Repo}
  alias Exchanger.Accounts.{Balance, Transaction, User, Wallet}

  @type response(data) :: {:ok, data} | {:error, :wallet_not_found}
  @type change_tuple(struct) :: {:ok, struct} | {:error, Ecto.Changeset.t()}
  @type user :: User.t()
  @type wallet :: Wallet.t()
  @type transaction :: Transaction.t()
  @type changeset :: Ecto.Changeset.t()
  @type id :: pos_integer
  @type amount :: pos_integer
  @type exchange_rate :: float
  @type currency :: String.t()
  @type params :: keyword | map

  @currencies Application.get_env(:exchanger, :currencies)

  # Users

  @spec all_users(params) :: {:ok, [User.t()]} | {:error, binary}
  def all_users(params) do
    # Sorry, I know it is ugly, but Dialyzer gives me a hard fail when I use Actions.all(User, params)
    result = Actions.all(from(u in User), params)
    {:ok, result}
  end

  @spec find_user(params) :: {:error, binary} | {:ok, User.t()}
  def find_user(params) do
    # Hard Dialyzer fail with Actions.find(User, params)
    from(u in User) |> Actions.find(params)
  end

  @spec list_users :: [user]
  def list_users do
    Repo.all(User)
  end

  @spec get_user!(id) :: user
  def get_user!(id), do: Repo.get!(User, id)

  @spec fetch_user_with_wallets(id) :: {:ok, user} | {:error, :user_not_found}
  def fetch_user_with_wallets(user_id) do
    user_id
    |> User.by_id()
    |> User.with_wallets()
    |> Repo.one()
    |> case do
      nil -> {:error, :user_not_found}
      %User{} = user -> {:ok, user}
    end
  end

  @spec create_user(params) :: {:error, Ecto.Changeset.t()} | {:ok, User.t()}
  def create_user(params) do
    Actions.create(User, params)
  end

  @spec update_user(%{id: binary}) :: {:error, Ecto.Changeset.t()} | {:ok, User.t()}
  def update_user(%{id: id} = params) do
    with {:ok, user} <- find_user(%{id: String.to_integer(id)}) do
      params = Map.delete(params, :id)
      Actions.update(User, user, params)
    end
  end

  # Wallets

  @spec all_wallets(params) :: {:ok, [Wallet.t()]} | {:error, binary}
  def all_wallets(params) do
    # Sorry, I know it is ugly, but Dialyzer gives me a hard fail when I use Actions.all(Wallet, params)
    result = Actions.all(from(u in Wallet), params)
    {:ok, result}
  end

  @spec fetch_user_balance(id, currency) :: {:ok, Balance.t()} | {:error, :user_not_found}
  def fetch_user_balance(user_id, currency) when currency in @currencies do
    case fetch_user_with_wallets(user_id) do
      {:ok, %User{wallets: wallets}} ->
        aggregate_balances(wallets, currency)

      error ->
        error
    end
  end

  defp aggregate_balances(wallets, currency, sum \\ 0)

  defp aggregate_balances([], currency, sum) do
    {:ok, %Balance{amount: sum, currency: currency, timestamp: Timex.now()}}
  end

  defp aggregate_balances([wallet | tail], currency, sum) do
    {:ok, %Balance{amount: amount}} =
      wallet
      |> get_wallet_balance!()
      |> ExchangeRate.equivalent_in_currency(currency)

    aggregate_balances(tail, currency, sum + amount)
  end

  @spec get_wallet_balance!(Wallet.t()) :: Balance.t()
  def get_wallet_balance!(%Wallet{id: id, currency: currency}) do
    %Wallet{sent_transactions: subs, received_transactions: adds} =
      id
      |> Wallet.where_id()
      |> Wallet.with_transactions()
      |> Repo.one!()

    additions = Enum.reduce(adds, 0, fn x, acc -> x.to_amount + acc end)
    subtractions = Enum.reduce(subs, 0, fn x, acc -> x.from_amount + acc end)
    %Balance{amount: additions - subtractions, currency: currency, timestamp: Timex.now()}
  end

  @spec find_wallet(params) :: {:error, binary} | {:ok, Wallet.t()}
  def find_wallet(params) do
    # Hard Dialyzer fail with Actions.find(Wallet, params)
    from(u in Wallet) |> Actions.find(params)
  end

  @spec get_wallet!(id) :: wallet
  def get_wallet!(id), do: Repo.get!(Wallet, id)

  @spec fetch_wallet_by_currency(user, currency) :: {:ok, wallet} | {:error, :wallet_not_found}
  def fetch_wallet_by_currency(%User{id: user_id}, currency) when currency in @currencies do
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

  @spec all_transactions(params) :: {:ok, [User.t()]} | {:error, binary}
  def all_transactions(params) do
    # Sorry, I know it is ugly, but Dialyzer gives me a hard fail when I use Actions.all(Transaction, params)
    result = Actions.all(from(u in Transaction), params)
    {:ok, result}
  end

  @spec find_transaction(params) :: {:error, binary} | {:ok, User.t()}
  def find_transaction(params) do
    # Hard Dialyzer fail with Actions.find(Transaction, params)
    from(u in Transaction) |> Actions.find(params)
  end

  @spec create_deposit(wallet, currency, amount) :: change_tuple(transaction)
  def create_deposit(%Wallet{} = wallet, currency, amount) when currency in @currencies do
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
