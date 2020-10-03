defmodule ExchangerWeb.UserChannel do
  @moduledoc false
  use ExchangerWeb, :channel
  alias Exchanger.Accounts.Balance

  @type user_id :: pos_integer

  @spec publish(Balance.t(), user_id) :: :ok
  def publish(%Balance{currency: currency} = balance, user_id) do
    Absinthe.Subscription.publish(ExchangerWeb.Endpoint, balance,
      net_worth_updated: "net_worth:#{user_id}-#{currency}"
    )
  end

  @spec join(binary, map, Phoenix.Socket.t()) :: {:ok, Phoenix.Socket.t()}
  def join(_, _payload, socket) do
    {:ok, socket}
  end
end
