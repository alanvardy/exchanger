defmodule Exchanger.ExchangeRate.Client.Http do
  @moduledoc "For querying the exchange rate api"
  alias HTTPoison.Response
  @behaviour Exchanger.ExchangeRate.Client.Behaviour

  @type currency :: String.t()
  @base_url "http://localhost:4001/query?function=CURRENCY_EXCHANGE_RATE&from_currency="
  @api_key "demo"

  @spec get_rate(currency, currency) :: {:error, String.t()} | {:ok, map}
  def get_rate(from_currency, to_currency) do
    with url <- "#{@base_url}#{from_currency}&to_currency=#{to_currency}&apikey=#{@api_key}",
         {:ok, %Response{status_code: 200, body: body}} <- HTTPoison.get(url),
         {:ok, decoded} <- Jason.decode(body) do
      {:ok, decoded}
    else
      {:ok, %Response{} = response} -> {:error, "Unrecognized response: #{response}"}
      error -> error
    end
  end
end
