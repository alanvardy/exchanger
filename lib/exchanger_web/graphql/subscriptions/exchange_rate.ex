defmodule ExchangerWeb.GraphQL.Subscriptions.ExchangeRate do
  @moduledoc "Currency subscriptions for Absinthe"
  use Absinthe.Schema.Notation

  object :exchange_rate_subscriptions do
    field :exchange_rate_updated, :exchange_rate do
      arg :currency, :currency

      config fn
        %{currency: nil}, _res ->
          {:ok, topic: "exchange_rate:all"}

        %{currency: currency}, _res when is_atom(currency) ->
          {:ok, topic: "exchange_rate:#{currency}"}

        _args, _res ->
          {:ok, topic: "exchange_rate:all"}
      end

      resolve fn exchange_rate, _args, _res -> {:ok, exchange_rate} end
    end
  end
end
