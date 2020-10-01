defmodule ExchangerWeb.Subscriptions.ExchangeRate do
  @moduledoc "Currency subscriptions for Absinthe"
  use Absinthe.Schema.Notation

  object :exchange_rate_subscriptions do
    field :exchange_rate_updated, :exchange_rate do
      config fn _args, _ -> {:ok, topic: "exchange_rate"} end

      # trigger :exchange_rate_updated,
      #   topic: fn _exchange_rate -> "exchange_rate" end

      resolve fn exchange_rate, _, _ -> {:ok, exchange_rate} end
    end
  end
end
