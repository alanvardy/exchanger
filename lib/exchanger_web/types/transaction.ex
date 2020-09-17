defmodule ExchangerWeb.Types.Transaction do
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
    field :from_currency, :string
    field :to_currency, :string
    field :from_amount, :integer
    field :to_amount, :integer
    field :exchange_rate, :float
    field :type, :string
    field :created_at, :string

    field :from_user, :user, resolve: dataloader(Exchanger.Accounts, :user)
    field :to_user, :user, resolve: dataloader(Exchanger.Accounts, :user)
    field :from_wallet, :wallet, resolve: dataloader(Exchanger.Accounts, :wallet)
    field :to_wallet, :wallet, resolve: dataloader(Exchanger.Accounts, :wallet)
  end
end
