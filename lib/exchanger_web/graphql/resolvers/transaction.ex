defmodule ExchangerWeb.GraphQL.Resolvers.Transaction do
  @moduledoc "Transaction resolvers for Absinthe"
  use Absinthe.Schema.Notation
  alias Exchanger.Accounts
  alias Exchanger.Accounts.Transaction

  @type params :: keyword | map

  @spec all(params, any) :: {:ok, [Transaction.t()]} | {:error, binary}
  def all(params, _res) do
    Accounts.all_transactions(params)
  end

  @spec find(params, any) :: {:error, binary} | {:ok, Transaction.t()}
  def find(params, _res) do
    Accounts.find_transaction(params)
  end

  @spec create_deposit(params, any) :: {:error, String.t()} | {:ok, Transaction.t()}
  def create_deposit(params, _res) do
    params
    |> Accounts.create_deposit()
    |> maybe_publish()
  end

  @spec create_withdrawal(params, any) :: {:error, String.t()} | {:ok, Transaction.t()}
  def create_withdrawal(params, _res) do
    params
    |> Accounts.create_withdrawal()
    |> maybe_publish()
  end

  @spec create_transfer(params, any) :: {:error, String.t()} | {:ok, Transaction.t()}
  def create_transfer(params, _res) do
    params
    |> Accounts.create_transfer()
    |> maybe_publish()
  end

  defp maybe_publish({:ok, transaction}) do
    Accounts.publish_net_worth_changes(transaction)
    {:ok, transaction}
  end

  defp maybe_publish(error), do: error
end
