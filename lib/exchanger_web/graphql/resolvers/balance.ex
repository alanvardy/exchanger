defmodule ExchangerWeb.GraphQL.Resolvers.Balance do
  @moduledoc "Balance resolvers for Absinthe"
  use Absinthe.Schema.Notation
  alias Exchanger.Accounts
  alias Exchanger.Accounts.Balance

  @type params :: keyword | map

  @spec get_net_worth(params, any) :: {:ok, Balance.t()} | {:error, binary}
  def get_net_worth(%{user_id: user_id, currency: currency}, _res) do
    Accounts.fetch_user_balance(user_id, currency)
  end
end
