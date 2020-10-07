defmodule Exchanger.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Changeset
  alias EctoShorts.Actions
  alias Exchanger.{ExchangeRate, Repo}
  alias Exchanger.Accounts.{Balance, Transaction, User, Wallet}
  alias ExchangerWeb.UserChannel

  @type response(data) :: {:ok, data} | {:error, :wallet_not_found}
  @type change_tuple(struct) :: {:ok, struct} | {:error, Changeset.t()}
  @type user :: User.t()
  @type wallet :: Wallet.t()
  @type transaction :: Transaction.t()
  @type changeset :: Changeset.t()
  @type id :: pos_integer
  @type amount :: pos_integer
  @type exchange_rate :: float
  @type currency :: Wallet.currency()
  @type params :: keyword | map

  @currencies Application.get_env(:exchanger, :currencies)

  # Users

  @spec all_users(params) :: {:ok, [User.t()]} | {:error, binary}
  def all_users(params) do
    # Sorry, I know it is ugly, but Dialyzer gives me a hard fail when I use Actions.all(User, params)
    {:ok, Actions.all(from(u in User), params)}
  end

  @spec find_user(params) :: {:error, binary} | {:ok, User.t()}
  def find_user(params) do
    # Hard Dialyzer fail with Actions.find(User, params)
    Actions.find(from(u in User), params)
  end

  defp fetch_user_with_wallets(user_id) do
    user_id
    |> User.by_id()
    |> User.with_wallets()
    |> Repo.one()
    |> case do
      nil -> {:error, :user_not_found}
      %User{} = user -> {:ok, user}
    end
  end

  @spec create_user(params) :: {:error, Changeset.t()} | {:ok, User.t()}
  def create_user(params) do
    Actions.create(User, params)
  end

  @spec update_user(%{id: binary}) :: {:error, Changeset.t()} | {:ok, User.t()}
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
    {:ok, Actions.all(from(u in Wallet), params)}
  end

  @spec publish_net_worth_changes(Transaction.t()) :: [any]
  def publish_net_worth_changes(%Transaction{from_user_id: from_user_id, to_user_id: to_user_id}) do
    user_ids = Enum.reject([from_user_id, to_user_id], &is_nil/1)

    for user_id <- user_ids, currency <- @currencies do
      with {:ok, balance} <- fetch_user_balance(user_id, currency) do
        UserChannel.publish(balance, user_id)
      end
    end
  end

  @spec fetch_user_balance(id, currency) :: {:ok, Balance.t()} | {:error, :user_not_found}
  def fetch_user_balance(user_id, currency) when currency in @currencies do
    with {:ok, %User{wallets: wallets}} <- fetch_user_with_wallets(user_id) do
      aggregate_balances(wallets, currency)
    end
  end

  defp aggregate_balances(wallets, currency, sum \\ 0)

  defp aggregate_balances([], currency, sum) do
    {:ok, %Balance{amount: sum, currency: currency, timestamp: Timex.now()}}
  end

  defp aggregate_balances([wallet | tail], currency, sum) do
    {:ok, %Balance{amount: amount}} =
      wallet
      |> get_wallet_balance()
      |> ExchangeRate.equivalent_in_currency(currency)

    aggregate_balances(tail, currency, sum + amount)
  end

  @spec get_wallet_balance(Wallet.t()) :: Balance.t()
  def get_wallet_balance(%Wallet{id: id}) do
    # Grab wallet again in case balance has changed
    %Wallet{currency: currency, balance: balance} = get_wallet!(id)
    %Balance{amount: balance, currency: currency, timestamp: Timex.now()}
  end

  @spec find_wallet(params) :: {:error, binary} | {:ok, Wallet.t()}
  def find_wallet(params) do
    # Hard Dialyzer fail with Actions.find(Wallet, params)
    Actions.find(from(u in Wallet), params)
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
    from(u in Transaction)
    |> Actions.all(params)
    |> case do
      {:error, message} -> {:error, message}
      transactions -> {:ok, Enum.map(transactions, &atomize_type/1)}
    end
  end

  @spec find_transaction(params) :: {:error, binary} | {:ok, User.t()}
  def find_transaction(params) do
    # Hard Dialyzer fail with Actions.find(Transaction, params)
    from(u in Transaction)
    |> Actions.find(params)
    |> atomize_type()
    |> case do
      {:error, message} -> {:error, message}
      transaction -> {:ok, transaction}
    end
  end

  @spec create_deposit(map) :: change_tuple(transaction)
  def create_deposit(params) do
    with %{to_currency: currency, to_user_id: user_id} <- params,
         {:ok, %Wallet{id: to_wallet_id}} <- find_wallet(%{user_id: user_id, currency: currency}) do
      params
      |> Map.merge(%{type: "deposit", to_wallet_id: to_wallet_id})
      |> Transaction.create_deposit_changeset()
      |> Repo.insert()
      |> maybe_format_changeset_errors()
    else
      params when is_map(params) -> {:error, "Cannot find wallet, invalid parameters"}
      {:error, _error} -> {:error, "Wallet not found for currency"}
    end
  end

  @spec create_withdrawal(map) :: change_tuple(transaction)
  def create_withdrawal(params) do
    with %{from_currency: currency, from_user_id: user_id} <- params,
         %{from_amount: from_amount} <- params,
         {:ok, wallet} <- find_wallet(%{user_id: user_id, currency: currency}),
         %Wallet{id: from_wallet_id, balance: balance} <- wallet,
         true <- from_amount <= balance do
      params
      |> Map.merge(%{type: "withdrawal", from_wallet_id: from_wallet_id})
      |> Transaction.create_withdrawal_changeset()
      |> Repo.insert()
      |> maybe_format_changeset_errors()
    else
      params when is_map(params) -> {:error, "Cannot find wallet, invalid parameters"}
      {:error, _error} -> {:error, "Wallet not found for currency"}
      false -> {:error, "Insufficient funds"}
    end
  end

  @spec create_transfer(map) :: change_tuple(transaction) | {:error, String.t()}
  def create_transfer(params) do
    with %{from_wallet_id: from_wallet_id, to_user_id: to_user_id} <- params,
         %{to_currency: to_currency, to_amount: to_amount} <- params,
         {:ok, to_wallet} <- find_wallet(%{user_id: to_user_id, currency: to_currency}),
         %Wallet{id: to_wallet_id} <- to_wallet,
         {:ok, from_wallet} <- find_wallet(%{id: from_wallet_id}),
         %Wallet{user_id: from_user_id} <- from_wallet,
         %Wallet{currency: from_currency, balance: from_balance} <- from_wallet,
         {:ok, %{rate: rate}} <- ExchangeRate.fetch(from_currency, to_currency),
         from_amount <- trunc(to_amount / rate),
         true <- from_amount <= from_balance do
      params
      |> Map.put(:exchange_rate, rate)
      |> Map.put(:to_wallet_id, to_wallet_id)
      |> Map.put(:from_user_id, from_user_id)
      |> Map.put(:from_currency, from_currency)
      |> Map.put(:type, "transfer")
      |> Map.put(:from_amount, from_amount)
      |> Transaction.create_transfer_changeset()
      |> Repo.insert()
      |> maybe_format_changeset_errors()
    else
      false -> {:error, "Insufficient funds"}
      params when is_map(params) -> {:error, "Invalid parameters for transfer"}
      {:error, :rate_not_found} -> {:error, "Could not fetch exchange rate"}
      {:error, error} -> {:error, "Wallet not found: #{error}"}
    end
  end

  defp atomize_type({:ok, %Transaction{type: type} = transaction}) do
    %Transaction{transaction | type: String.to_existing_atom(type)}
  end

  defp atomize_type(%Transaction{type: type} = transaction) do
    %Transaction{transaction | type: String.to_existing_atom(type)}
  end

  defp atomize_type({:error, message}) do
    {:error, message}
  end

  defp maybe_format_changeset_errors({:error, %Changeset{} = changeset}) do
    errors =
      changeset
      |> Changeset.traverse_errors(fn {msg, opts} ->
        Enum.reduce(opts, msg, fn {key, value}, acc ->
          String.replace(acc, "%{#{key}}", to_string(value))
        end)
      end)
      |> Enum.reduce("", fn {k, v}, acc ->
        joined_errors = Enum.join(v, "; ")
        "#{acc}#{k}: #{joined_errors}"
      end)

    {:error, errors}
  end

  defp maybe_format_changeset_errors({:ok, struct}) do
    {:ok, struct}
  end
end
