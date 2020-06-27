defmodule Exchanger.ExchangeRate.Api do
  @moduledoc "For querying the exchange rate api"
  alias HTTPoison.Response

  @type currency :: String.t()
  @base_url "https://api.exchangeratesapi.io/latest?base="

  @spec get_rates(currency, [currency]) :: :error | {:ok, map}
  def get_rates(currency, currencies) do
    with url <- "#{@base_url}#{currency}&symbols=#{Enum.join(currencies, ",")}",
         {:ok, %Response{status_code: 200, body: body}} <- HTTPoison.get(url),
         {:ok, decoded} <- Jason.decode(body),
         converted <- convert(decoded) do
      {:ok, converted}
    else
      _ -> :error
    end
  end

  defp convert(%{"base" => base, "rates" => rates}) do
    %{base => %{"datetime" => DateTime.utc_now(), "rates" => rates}}
  end
end
