defmodule ExchangerWeb.SubscriptionCase do
  @moduledoc "Test case for GraphQL subscriptions"
  use ExUnit.CaseTemplate
  alias Absinthe.Phoenix.SubscriptionTest

  using do
    quote do
      use ExchangerWeb.ChannelCase
      use SubscriptionTest, schema: ExchangerWeb.GraphQL.Schema
      import Exchanger.Factory

      setup do
        {:ok, socket} = Phoenix.ChannelTest.connect(ExchangerWeb.UserSocket, %{})
        {:ok, socket} = SubscriptionTest.join_absinthe(socket)

        {:ok, %{socket: socket}}
      end
    end
  end
end
