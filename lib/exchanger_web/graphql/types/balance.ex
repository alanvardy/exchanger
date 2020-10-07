defmodule ExchangerWeb.GraphQL.Types.Balance do
  @moduledoc "User types for Absinthe"
  use Absinthe.Schema.Notation

  @desc "A balance in a currency at a point in time"
  object :balance do
    field :amount, :integer
    field :currency, :currency
    field :timestamp, :string
  end
end
