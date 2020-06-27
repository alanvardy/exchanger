defmodule Exchanger.ExchangeRate.Api do
  @moduledoc "For querying the exchange rate api"
  alias HTTPoison.Response

  @base_url "https://api.exchangeratesapi.io/latest?base="

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
