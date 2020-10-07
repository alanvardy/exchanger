defmodule ExchangerWeb.GraphQL.Queries.WalletTest do
  use Exchanger.DataCase, async: true

  @wallet_doc """
    query findWallet($id: ID, $user_id: ID, $currency: Currency) {
      wallet(id: $id, user_id: $user_id, currency: $currency) {
        id,
        user_id,
        currency,
        user {
          id,
          first_name,
          last_name
        }
      }
    }
  """

  @wallets_doc """
    query findWallets($user_id: ID, $currency: Currency) {
      wallets(user_id: $user_id, currency: $currency) {
        id,
        user_id,
        currency
      }
    }
  """

  setup do
    user = insert(:user)
    wallet = insert(:wallet, user_id: user.id)
    %{user: user, wallet: wallet}
  end

  describe "@wallet" do
    test "Can get wallet by currency", %{wallet: wallet} do
      wallet_id =
        @wallet_doc
        |> run_schema(%{"currency" => to_string(wallet.currency)})
        |> get_in([:data, "wallet", "id"])
        |> String.to_integer()

      assert wallet_id === wallet.id
    end

    test "Gets the wallets owner", %{wallet: wallet, user: user} do
      user_id =
        @wallet_doc
        |> run_schema(%{"currency" => to_string(wallet.currency)})
        |> get_in([:data, "wallet", "user", "id"])
        |> String.to_integer()

      assert user_id === user.id
    end

    test "Can get wallet by user_id", %{user: user, wallet: wallet} do
      wallet_id =
        @wallet_doc
        |> run_schema(%{"user_id" => user.id})
        |> get_in([:data, "wallet", "id"])
        |> String.to_integer()

      assert wallet_id === wallet.id
    end
  end

  describe "@wallets" do
    test "Can get wallets by user_id", %{user: user, wallet: wallet1} do
      wallet2 = insert(:wallet, user_id: user.id)

      wallet_ids =
        @wallets_doc
        |> run_schema(%{"user_id" => user.id})
        |> get_in([:data, "wallets"])
        |> Enum.map(&String.to_integer(&1["id"]))

      assert Enum.sort(wallet_ids) === Enum.sort([wallet1.id, wallet2.id])
    end
  end
end
