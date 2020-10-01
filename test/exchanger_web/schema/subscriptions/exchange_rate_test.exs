defmodule ExchangerWeb.Subscriptions.ExchangeRateTest do
  use ExchangerWeb.SubscriptionCase

  @exchange_rate_updated_doc """
  subscription {
      exchangeRateUpdated {
          from
          to
          rate
          updated
      }
    }
  """

  describe "@exchange_rate_updated" do
    test "send the new exchange rate when it is updated", %{socket: socket} do
      # Subscribe to the topic
      ref = push_doc(socket, @exchange_rate_updated_doc, [])
      assert_reply(ref, :ok, %{subscriptionId: subscription_id})

      # The exchange rate is updating constantly
      assert_push("subscription:data", data)

      assert %{
               subscriptionId: ^subscription_id,
               result: %{
                 data: %{
                   "exchangeRateUpdated" => %{
                     "from" => "USD",
                     "to" => "CAD",
                     "rate" => 1.34
                   }
                 }
               }
             } = data
    end
  end
end
