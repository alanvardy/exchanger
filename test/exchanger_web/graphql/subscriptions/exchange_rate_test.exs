defmodule ExchangerWeb.GraphQL.Subscriptions.ExchangeRateTest do
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
    test "get USD and CAD exchange rates when subscribed to all exchange rates", %{socket: socket} do
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

      assert_push("subscription:data", data)

      assert %{
               subscriptionId: ^subscription_id,
               result: %{
                 data: %{
                   "exchangeRateUpdated" => %{
                     "from" => "CAD",
                     "to" => "USD",
                     "rate" => 0.75
                   }
                 }
               }
             } = data
    end

    @usd_updated_doc """
      subscription($currency: Currency) {
        exchangeRateUpdated(currency: $currency) {
            from
            to
            rate
            updated
        }
      }
    """

    test "only gets USD when subscribed to USD", %{socket: socket} do
      # Subscribe to the topic
      ref = push_doc(socket, @usd_updated_doc, variables: %{"currency" => "USD"})
      assert_reply(ref, :ok, %{subscriptionId: subscription_id})

      :timer.sleep(200)

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

      refute_push("subscription:data", %{
        subscriptionId: ^subscription_id,
        result: %{
          data: %{
            "exchangeRateUpdated" => %{
              "from" => "CAD",
              "to" => "USD",
              "rate" => 0.75
            }
          }
        }
      })
    end
  end
end
