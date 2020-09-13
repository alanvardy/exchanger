defmodule ExchangerWeb.Resolvers.Wallet do
  @moduledoc "Wallet resolvers for Absinthe"
  use Absinthe.Schema.Notation
  alias Exchanger.Accounts
  alias Exchanger.Accounts.{User, Wallet}

  @type params :: keyword | map

  @spec find(params, any) :: {:error, binary} | {:ok, Wallet.t()}
  def find(params, _) do
    Accounts.find_wallet(params)
  end

  @spec all(params, any) :: {:ok, [User.t()]} | {:error, binary}
  def all(params, _) do
    Accounts.all_wallets(params)
  end
end
