defmodule Exchanger.ExchangeRate.Client do
  @moduledoc "For accessing the mock or AlphaVantage Exchange Rate API"

  alias Exchanger.Accounts.Wallet
  alias Exchanger.ExchangeRate.ExchangeRate

  @type currency :: Wallet.currency()
  @client Application.get_env(:exchanger, :api_client)

  @spec get_rate(currency, currency) :: {:error, String.t()} | {:ok, ExchangeRate.t()}
  def get_rate(from_currency, to_currency) do
    with {:ok, rate} <- @client.get_rate(from_currency, to_currency) do
      convert(rate)
    end
  end

  defp convert(body) do
    case body do
      %{
        "Realtime Currency Exchange Rate" => %{
          "1. From_Currency Code" => from,
          "3. To_Currency Code" => to,
          "5. Exchange Rate" => rate,
          "6. Last Refreshed" => updated
        }
      } ->
        {:ok,
         %ExchangeRate{
           from: String.to_existing_atom(from),
           to: String.to_existing_atom(to),
           rate: String.to_float(rate),
           updated: Timex.parse!(updated, "{RFC3339}")
         }}

      body ->
        {:error, "Unrecognized body: #{body}"}
    end
  end
end
