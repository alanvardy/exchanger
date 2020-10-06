defmodule ExchangerWeb.Queries.Transaction do
  @moduledoc "Absinthe queries for transactions"
  use Absinthe.Schema.Notation
  alias ExchangerWeb.Resolvers

  object :transaction_queries do
    field :transactions, list_of(:transaction) do
      arg :from_user_id, :id
      arg :from_wallet_id, :id
      arg :from_currency, :currency
      arg :to_user_id, :id
      arg :to_wallet_id, :id
      arg :to_currency, :currency
      arg :type, :string
      arg :start_date, :string
      resolve &Resolvers.Transaction.all/2
    end

    field :transaction, :transaction do
      arg :id, :id
      arg :from_user_id, :id
      arg :from_wallet_id, :id
      arg :from_currency, :currency
      arg :to_user_id, :id
      arg :to_wallet_id, :id
      arg :to_currency, :currency
      arg :type, :string
      resolve &Resolvers.Transaction.find/2
    end
  end
end
