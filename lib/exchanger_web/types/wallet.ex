defmodule ExchangerWeb.Types.Wallet do
  @moduledoc "Wallet types for Absinthe"
  use Absinthe.Schema.Notation
  import Absinthe.Resolution.Helpers, only: [dataloader: 2]

  @desc "A users wallet, can hold one type of currency"
  object :wallet do
    field :id, :id
    field :user_id, :id
    field :currency, :string
    field :balance, :integer

    field :user, :user, resolve: dataloader(Exchanger.Accounts, :user)
  end
end
