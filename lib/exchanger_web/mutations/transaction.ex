defmodule ExchangerWeb.Mutations.Transaction do
  @moduledoc "Transaction Mutations for Absinthe"
  use Absinthe.Schema.Notation
  alias ExchangerWeb.Resolvers

  object :transaction_mutations do
    field :create_deposit, :transaction do
      arg :to_user_id, :id
      arg :to_currency, :string
      arg :to_amount, :integer
      resolve &Resolvers.Transaction.create_deposit/2
    end

    field :create_withdrawal, :transaction do
      arg :from_user_id, :id
      arg :from_currency, :string
      arg :from_amount, :integer
      resolve &Resolvers.Transaction.create_withdrawal/2
    end

    field :create_transfer, :transaction do
      arg :to_user_id, :id
      arg :from_wallet_id, :id
      arg :to_currency, :string
      arg :to_amount, :integer
      resolve &Resolvers.Transaction.create_transfer/2
    end
  end
end
