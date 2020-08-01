defmodule Exchanger.ExchangeRate.Client.Local do
  @moduledoc "For querying the exchange rate api"
  @behaviour Exchanger.ExchangeRate.Client.Behaviour

  def get_rate("USD", "CAD") do
    {:ok,
     %{
       "Realtime Currency Exchange Rate" => %{
         "1. From_Currency Code" => "USD",
         "2. From_Currency Name" => "US Dollar",
         "3. To_Currency Code" => "CAD",
         "4. To_Currency Name" => "Canadian Dollar",
         "5. Exchange Rate" => "1.34",
         "6. Last Refreshed" => Timex.now() |> Timex.format!("{RFC3339}"),
         "7. Time Zone" => "UTC",
         "8. Bid Price" => "3.52",
         "9. Ask Price" => "3.52"
       }
     }}
  end

  def get_rate("CAD", "USD") do
    {:ok,
     %{
       "Realtime Currency Exchange Rate" => %{
         "1. From_Currency Code" => "CAD",
         "2. From_Currency Name" => "Canadian Dollar",
         "3. To_Currency Code" => "USD",
         "4. To_Currency Name" => "US Dollar",
         "5. Exchange Rate" => "0.75",
         "6. Last Refreshed" => Timex.now() |> Timex.format!("{RFC3339}"),
         "7. Time Zone" => "UTC",
         "8. Bid Price" => "2.33",
         "9. Ask Price" => "2.33"
       }
     }}
  end
end
