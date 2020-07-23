defmodule Exchanger.ExchangeRate.Api do
  @moduledoc "For querying the exchange rate api"
  alias HTTPoison.Response

  @type currency :: String.t()
  @base_url "http://localhost:4001/query?function=CURRENCY_EXCHANGE_RATE&from_currency="
  @api_key "demo"

  @spec get_rate(currency, currency) :: {:error, String.t()} | {:ok, map}
  def get_rate(from_currency, to_currency) do
    with url <- "#{@base_url}#{from_currency}&to_currency=#{to_currency}&apikey=#{@api_key}",
         {:ok, %Response{status_code: 200, body: body}} <- HTTPoison.get(url),
         {:ok, decoded} <- Jason.decode(body),
         {:ok, converted} <- convert(decoded) do
      {:ok, converted}
    end
  end

  defp convert(response) do
    case response do
      %{
        "Realtime Currency Exchange Rate" => %{
          "1. From_Currency Code" => from,
          "3. To_Currency Code" => to,
          "5. Exchange Rate" => rate,
          "6. Last Refreshed" => updated
        }
      } ->
        {:ok, %{currencies: [from, to], rate: rate, updated: Timex.parse!(updated, "{RFC3339}")}}

      response ->
        {:error, "Unrecognized response: #{response}"}
    end
  end
end
