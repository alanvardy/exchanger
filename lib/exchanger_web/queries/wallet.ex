defmodule ExchangerWeb.Queries.Wallet do
  @moduledoc "Absinthe queries for wallets"
  use Absinthe.Schema.Notation
  alias ExchangerWeb.Resolvers

  object :wallet_queries do
    field :wallets, list_of(:wallet) do
      arg(:user_id, :id)
      arg(:currency, :string)
      resolve(&Resolvers.Wallet.all/2)
    end

    field :wallet, :wallet do
      arg(:id, :id)
      arg(:user_id, :id)
      arg(:currency, :string)
      resolve(&Resolvers.Wallet.find/2)
    end
  end
end
