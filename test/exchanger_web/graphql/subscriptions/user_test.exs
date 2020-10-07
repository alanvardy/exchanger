defmodule ExchangerWeb.GraphQL.Subscriptions.UserTest do
  use ExchangerWeb.SubscriptionCase

  @net_worth_updated_doc """
  subscription($user_id: ID, $currency: Currency) {
      netWorthUpdated(user_id: $user_id, currency: $currency) {
          amount
          currency
          timestamp
      }
    }
  """

  @create_deposit_doc """
    mutation createDeposit($to_user_id: ID, $to_amount: Int, $to_currency: Currency) {
      create_deposit(to_user_id: $to_user_id, to_amount: $to_amount, to_currency: $to_currency) {
        id
      }
    }
  """

  setup do
    user = insert(:user)
    wallet = insert(:wallet, user: user, currency: "USD")
    [user: user, wallet: wallet]
  end

  describe "@net_worth_updated" do
    test "gets a net worth update when a deposit is made", %{socket: socket, user: user} do
      # Subscribe to the topic
      ref =
        push_doc(socket, @net_worth_updated_doc,
          variables: %{"user_id" => user.id, "currency" => "USD"}
        )

      assert_reply(ref, :ok, %{subscriptionId: subscription_id})

      # Make a deposit
      ref =
        push_doc(socket, @create_deposit_doc,
          variables: %{"to_user_id" => user.id, "to_amount" => 5000, to_currency: "USD"}
        )

      # Assert deposit update response
      assert_reply(ref, :ok, reply)

      # Assert the receipt of net worth update
      assert_push("subscription:data", data)

      assert %{
               subscriptionId: ^subscription_id,
               result: %{
                 data: %{
                   "netWorthUpdated" => %{
                     "currency" => "USD",
                     "amount" => 5000
                   }
                 }
               }
             } = data
    end

    test "can get net worth in a different currency", %{socket: socket, user: user} do
      # Subscribe to the topic
      ref =
        push_doc(socket, @net_worth_updated_doc,
          variables: %{"user_id" => user.id, "currency" => "CAD"}
        )

      assert_reply(ref, :ok, %{subscriptionId: subscription_id})

      # Make a deposit
      ref =
        push_doc(socket, @create_deposit_doc,
          variables: %{"to_user_id" => user.id, "to_amount" => 5000, to_currency: "USD"}
        )

      # Assert deposit update response
      assert_reply(ref, :ok, reply)

      # Assert the receipt of net worth update
      assert_push("subscription:data", data)

      assert %{
               subscriptionId: ^subscription_id,
               result: %{
                 data: %{
                   "netWorthUpdated" => %{
                     "currency" => "CAD",
                     "amount" => 6700
                   }
                 }
               }
             } = data
    end
  end
end
