defmodule ExchangerWeb.GraphQL.Resolvers.Wallet do
  @moduledoc "Wallet resolvers for Absinthe"
  use Absinthe.Schema.Notation
  alias Exchanger.Accounts
  alias Exchanger.Accounts.{User, Wallet}

  @type params :: keyword | map

  @spec find(params, any) :: {:error, binary} | {:ok, Wallet.t()}
  def find(params, _res) do
    Accounts.find_wallet(params)
  end

  @spec all(params, any) :: {:ok, [User.t()]} | {:error, binary}
  def all(params, _res) do
    Accounts.all_wallets(params)
  end

  @spec create(params, any) :: {:error, Ecto.Changeset.t()} | {:ok, Wallet.t()}
  def create(params, _res) do
    Accounts.create_wallet(params)
  end
end
