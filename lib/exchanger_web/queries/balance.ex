defmodule ExchangerWeb.Queries.Balance do
  @moduledoc "Absinthe queries for balances"
  use Absinthe.Schema.Notation
  alias ExchangerWeb.Resolvers

  object :balance_queries do
    field :net_worth, :balance do
      arg :user_id, non_null(:id)
      arg :currency, non_null(:string)
      resolve &Resolvers.Balance.get_net_worth/2
    end
  end
end
