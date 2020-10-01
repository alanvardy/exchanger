defmodule ExchangerWeb.SubscriptionCase do
  @moduledoc "Test case for GraphQL subscriptions"
  alias Absinthe.Phoenix.SubscriptionTest

  use ExUnit.CaseTemplate

  using do
    quote do
      use ExchangerWeb.ChannelCase
      use SubscriptionTest, schema: ExchangerWeb.Schema

      setup do
        {:ok, socket} = Phoenix.ChannelTest.connect(ExchangerWeb.UserSocket, %{})
        {:ok, socket} = SubscriptionTest.join_absinthe(socket)

        {:ok, %{socket: socket}}
      end
    end
  end
end
