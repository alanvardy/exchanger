defmodule ExchangerWeb.Mutations.Transaction do
  @moduledoc "Transaction Mutations for Absinthe"
  use Absinthe.Schema.Notation
  alias ExchangerWeb.Resolvers

  object :transaction_mutations do
    field :create_deposit, :transaction do
      arg :to_user_id, non_null(:id)
      arg :to_currency, non_null(:currency)
      arg :to_amount, non_null(:integer)
      resolve &Resolvers.Transaction.create_deposit/2
    end

    field :create_withdrawal, :transaction do
      arg :from_user_id, non_null(:id)
      arg :from_currency, non_null(:currency)
      arg :from_amount, non_null(:integer)
      resolve &Resolvers.Transaction.create_withdrawal/2
    end

    field :create_transfer, :transaction do
      arg :to_user_id, non_null(:id)
      arg :from_wallet_id, non_null(:id)
      arg :to_currency, non_null(:currency)
      arg :to_amount, non_null(:integer)
      resolve &Resolvers.Transaction.create_transfer/2
    end
  end
end
