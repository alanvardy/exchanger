defmodule Exchanger.ExchangeRate do
  @moduledoc "The ExchangeRate context which holds all knowledge regarding the current exchange rates"
  alias Exchanger.Accounts.Balance

  @type response(data) :: {:ok, data} | {:error, :rate_not_found}
  @type currency :: String.t()

  @spec fetch(currency, currency, pid) :: response(%{rate: float, updated: DateTime.t()})
  defdelegate fetch(from_currency, to_currency, pid), to: Exchanger.ExchangeRate.Store, as: :fetch_rate

  @spec equivalent_in_currency(Balance.t(), currency) :: response(Balance.t())
  def equivalent_in_currency(%Balance{amount: amount, currency: from_currency}, to_currency) do
    case fetch(from_currency, to_currency, self()) do
      {:ok, %{rate: rate}} ->
        amount = floor(amount * rate)
        {:ok, %Balance{amount: amount, currency: to_currency, timestamp: Timex.now()}}

      error ->
        error
    end
  end
end
