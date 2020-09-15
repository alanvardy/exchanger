defmodule ExchangerWeb.Types.Balance do
  @moduledoc "User types for Absinthe"
  use Absinthe.Schema.Notation

  @desc "A balance in a currency at a point in time"
  object :balance do
    field :amount, :integer
    field :currency, :string
    field :timestamp, :string
  end
end
