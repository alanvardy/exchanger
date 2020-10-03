defmodule ExchangerWeb.ExchangeRateChannel do
  @moduledoc false
  use ExchangerWeb, :channel
  alias Exchanger.ExchangeRate.ExchangeRate

  def publish(%ExchangeRate{from: from} = exchange_rate) do
    Absinthe.Subscription.publish(ExchangerWeb.Endpoint, exchange_rate,
      exchange_rate_updated: "exchange_rate:all"
    )

    Absinthe.Subscription.publish(ExchangerWeb.Endpoint, exchange_rate,
      exchange_rate_updated: "exchange_rate:#{from}"
    )
  end

  @spec join(binary, map, Phoenix.Socket.t()) :: {:ok, Phoenix.Socket.t()}
  def join(_, _payload, socket) do
    {:ok, socket}
  end
end
