defmodule ExchangerWeb.GraphQL.Types.ExchangeRate do
  @moduledoc "Exchange rate types for Absinthe"
  use Absinthe.Schema.Notation

  @desc "An exchange rate between 2 currencies at a point in time"
  object :exchange_rate do
    field :from, :currency
    field :to, :currency
    field :rate, :float
    field :updated, :string
  end
end
