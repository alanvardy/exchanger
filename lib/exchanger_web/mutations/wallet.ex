defmodule ExchangerWeb.Mutations.Wallet do
  @moduledoc "Wallet Mutations for Absinthe"
  use Absinthe.Schema.Notation
  alias ExchangerWeb.Resolvers

  object :wallet_mutations do
    field :create_wallet, :wallet do
      arg(:user_id, :id)
      arg(:currency, :string)
      resolve(&Resolvers.Wallet.create/2)
    end
  end
end
