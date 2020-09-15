defmodule ExchangerWeb.Schema.Queries.BalanceTest do
  use Exchanger.DataCase, async: true

  @net_worth_doc """
    query getNetWorth($user_id: ID, $currency: String) {
      net_worth(user_id: $user_id, currency: $currency) {
        amount,
        currency,
        timestamp
      }
    }
  """

  setup do
    %{user: insert(:user)}
  end

  describe "@net_worth" do
    test "Can get net worth of a user", %{user: user} do
      balance =
        @net_worth_doc
        |> run_schema(%{"user_id" => user.id, "currency" => "USD"})
        |> get_in(["net_worth", "amount"])

      assert balance === 0
    end
  end
end
