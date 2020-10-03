defmodule ExchangerWeb.Subscriptions.User do
  @moduledoc "User subscriptions for Absinthe"
  use Absinthe.Schema.Notation

  object :user_subscriptions do
    field :net_worth_updated, :balance do
      arg :user_id, :id
      arg :currency, :string

      config fn
        %{user_id: user_id, currency: currency}, _res when is_bitstring(currency) ->
          {:ok, topic: "net_worth:#{user_id}-#{currency}"}
      end

      resolve fn balance, _args, _res -> {:ok, balance} end
    end
  end
end