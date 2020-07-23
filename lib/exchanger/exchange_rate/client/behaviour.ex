defmodule Exchanger.ExchangeRate.Client.Behaviour do
  @moduledoc "Behaviour for implementing the exchange rate client"
  @callback get_rate(String.t(), String.t()) :: {:ok, map} | {:error, String.t()}
end
