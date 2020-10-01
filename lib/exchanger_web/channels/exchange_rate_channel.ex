defmodule ExchangerWeb.ExchangeRateChannel do
  @moduledoc false
  use ExchangerWeb, :channel

  def publish(exchange_rate) do
    Absinthe.Subscription.publish(ExchangerWeb.Endpoint, exchange_rate,
      exchange_rate_updated: "exchange_rate"
    )
  end

  @spec join(binary, map, Phoenix.Socket.t()) :: {:ok, Phoenix.Socket.t()}
  def join(_, _payload, socket) do
    {:ok, socket}
  end
end
