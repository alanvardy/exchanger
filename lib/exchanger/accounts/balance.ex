defmodule Exchanger.Accounts.Balance do
  @moduledoc "A wallet or aggregate balance"
  use TypedStruct

  alias Exchanger.Accounts.Wallet

  @type currency :: Wallet.currency()

  typedstruct do
    @typedoc @moduledoc

    field :amount, integer, enforce: true
    field :currency, currency, enforce: true
    field :timestamp, DateTime.t(), enforce: true
  end
end
