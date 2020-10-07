defmodule ExchangerWeb.GraphQL.Types.Transaction do
  @moduledoc "Transaction types for Absinthe"
  use Absinthe.Schema.Notation
  import Absinthe.Resolution.Helpers, only: [dataloader: 2]

  @desc "A users wallet, can hold one type of currency"
  object :transaction do
    field :id, :id
    field :from_user_id, :id
    field :to_user_id, :id
    field :from_wallet_id, :id
    field :to_wallet_id, :id
    field :from_currency, :currency
    field :to_currency, :currency
    field :from_amount, :integer
    field :to_amount, :integer
    field :exchange_rate, :float
    field :type, :transaction_type
    field :inserted_at, :datetime

    field :from_user, :user, resolve: dataloader(Exchanger.Accounts, :user)
    field :to_user, :user, resolve: dataloader(Exchanger.Accounts, :user)
    field :from_wallet, :wallet, resolve: dataloader(Exchanger.Accounts, :wallet)
    field :to_wallet, :wallet, resolve: dataloader(Exchanger.Accounts, :wallet)
  end

  enum :transaction_type do
    description "The type of transaction"

    value :deposit, description: "Money being deposited into account"
    value :withdrawal, description: "Money being withdrawn from account"
    value :transfer, description: "Money transferred from one account to another"
  end
end
