defmodule Exchanger.ExchangeRate.Client.Behaviour do
  @moduledoc "Behaviour for implementing the exchange rate client"
  @type currency :: :USD | :CAD | :GBP
  @callback get_rate(currency, currency) :: {:ok, map} | {:error, String.t()}
end
