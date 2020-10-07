defmodule Exchanger.ExchangeRate.Client.Http do
  @moduledoc "For querying the exchange rate api"
  @behaviour Exchanger.ExchangeRate.Client.Behaviour
  alias Exchanger.Accounts.Wallet
  alias HTTPoison.Response

  @type currency :: Wallet.currency()

  @address Application.get_env(:exchanger, :exchange_rate_address)
  @query "/query?function=CURRENCY_EXCHANGE_RATE&from_currency="
  @api_key Application.get_env(:exchanger, :exchange_rate_api_key)

  @spec get_rate(currency, currency) :: {:error, String.t()} | {:ok, map}
  def get_rate(from_currency, to_currency) do
    with url <-
           "#{@address}#{@query}#{from_currency}&to_currency=#{to_currency}&apikey=#{@api_key}",
         {:ok, %Response{status_code: 200, body: body}} <- HTTPoison.get(url),
         {:ok, decoded} <- Jason.decode(body) do
      {:ok, decoded}
    else
      {:ok, %Response{} = response} -> {:error, "Unrecognized response: #{response}"}
      error -> error
    end
  end
end
