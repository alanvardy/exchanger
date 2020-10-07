defmodule Exchanger.ExchangeRate.Client.Behaviour do
  @moduledoc "Behaviour for implementing the exchange rate client"
  alias Exchanger.Accounts.Wallet

  @callback get_rate(Wallet.currency(), Wallet.currency()) :: {:ok, map} | {:error, String.t()}
end
