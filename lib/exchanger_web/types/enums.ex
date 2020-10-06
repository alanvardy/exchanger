defmodule ExchangerWeb.Types.Enums do
  @moduledoc "Enum types for Absinthe"
  use Absinthe.Schema.Notation

  @desc "A type of currency"
  enum :currency, values: [:USD, :CAD, :GBP]
end
