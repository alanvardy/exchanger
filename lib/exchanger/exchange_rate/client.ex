defmodule Exchanger.ExchangeRate.Client do
  @moduledoc "For accessing the mock or AlphaVantage Exchange Rate API"

  @client Application.get_env(:exchanger, :api_client)

  def get_rate(from_currency, to_currency) do
    case @client.get_rate(from_currency, to_currency) do
      {:ok, rate} -> convert(rate)
      error -> error
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
         %{
           currencies: {from, to},
           rate: String.to_float(rate),
           updated: Timex.parse!(updated, "{RFC3339}")
         }}

      body ->
        {:error, "Unrecognized body: #{body}"}
    end
  end
end
