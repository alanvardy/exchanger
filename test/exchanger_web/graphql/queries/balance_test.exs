defmodule ExchangerWeb.GraphQL.Queries.BalanceTest do
  use Exchanger.DataCase, async: true

  @net_worth_doc """
    query getNetWorth($user_id: ID, $currency: Currency) {
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
    test "Can get net worth of a user when no transactions", %{user: user} do
      balance =
        @net_worth_doc
        |> run_schema(%{"user_id" => user.id, "currency" => "USD"})
        |> get_in([:data, "net_worth", "amount"])

      assert balance === 0
    end

    test "Can get net worth of a user", %{user: user} do
      wallet = insert(:wallet, currency: :USD, user: user)
      insert(:deposit, to_currency: :USD, to_amount: 10_000, to_wallet: wallet)

      balance =
        @net_worth_doc
        |> run_schema(%{"user_id" => user.id, "currency" => "USD"})
        |> get_in([:data, "net_worth", "amount"])

      assert balance === 10_000
    end

    test "Can get net worth of a user over multiple currencies", %{user: user} do
      wallet = insert(:wallet, currency: :USD, user: user)
      insert(:deposit, to_currency: :USD, to_amount: 10_000, to_wallet: wallet)
      insert(:deposit, to_currency: :CAD, to_amount: 20_000, to_wallet: wallet)

      balance =
        @net_worth_doc
        |> run_schema(%{"user_id" => user.id, "currency" => "CAD"})
        |> get_in([:data, "net_worth", "amount"])

      assert balance === 40_200
    end
  end
end
