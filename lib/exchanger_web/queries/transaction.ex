defmodule ExchangerWeb.Queries.Transaction do
  @moduledoc "Absinthe queries for users"
  use Absinthe.Schema.Notation
  alias ExchangerWeb.Resolvers

  object :transaction_queries do
    field :transactions, list_of(:transaction) do
      arg :from_user_id, :id
      arg :from_wallet_id, :id
      arg :from_currency, :string
      arg :to_user_id, :id
      arg :to_wallet_id, :id
      arg :to_currency, :string
      resolve &Resolvers.Transaction.all/2
    end

    field :transaction, :transaction do
      arg :id, :id
      arg :from_user_id, :id
      arg :from_wallet_id, :id
      arg :from_currency, :string
      arg :to_user_id, :id
      arg :to_wallet_id, :id
      arg :to_currency, :string
      resolve &Resolvers.Transaction.find/2
    end
  end
end
