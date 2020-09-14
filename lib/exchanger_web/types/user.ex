defmodule ExchangerWeb.Types.User do
  @moduledoc "User types for Absinthe"
  use Absinthe.Schema.Notation
  import Absinthe.Resolution.Helpers, only: [dataloader: 2]

  @desc "A real human"
  object :user do
    field :id, :id
    field :first_name, :string
    field :last_name, :string

    field :wallets, list_of(:wallet), resolve: dataloader(Exchanger.Accounts, :wallets)
  end
end
