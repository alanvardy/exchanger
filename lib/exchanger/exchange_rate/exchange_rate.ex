defmodule Exchanger.ExchangeRate.ExchangeRate do
  @moduledoc "Represents an exchange rate at a point in time"
  use TypedStruct
  alias Exchanger.Accounts.Wallet

  @type currency :: Wallet.currency()

  typedstruct do
    @typedoc @moduledoc

    field :from, currency, enforce: true
    field :to, currency, enforce: true
    field :rate, float()
    field :updated, DateTime.t(), enforce: true
  end
end
