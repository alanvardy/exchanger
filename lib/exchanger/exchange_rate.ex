defmodule Exchanger.ExchangeRate do
  @moduledoc "The ExchangeRate context which holds all knowledge regarding the current exchange rates"
  @type response :: {:error, :rate_not_found} | {:ok, %{rate: float, updated: DateTime.t()}}

  @spec fetch(binary, binary) :: response
  defdelegate fetch(from_currency, to_currency), to: Exchanger.ExchangeRate.Store, as: :fetch_rate
end
