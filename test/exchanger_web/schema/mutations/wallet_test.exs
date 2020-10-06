defmodule ExchangerWeb.Schema.Mutations.WalletTest do
  use Exchanger.DataCase, async: true
  alias Exchanger.Accounts

  @create_wallet_doc """
    mutation createWallet($user_id: ID, $currency: Currency) {
      create_wallet(user_id: $user_id, currency: $currency) {
        currency
        balance
      }
    }
  """

  describe "@create_wallet" do
    test "creates a wallet" do
      user = insert(:user)
      {:ok, wallets} = Accounts.all_wallets(%{})
      assert Enum.empty?(wallets)

      run_schema(@create_wallet_doc, %{"currency" => "USD", "user_id" => user.id})

      {:ok, wallets} = Accounts.all_wallets(%{})
      assert Enum.count(wallets) == 1
      assert List.first(wallets).currency == :USD
      assert List.first(wallets).user_id == user.id
    end
  end
end
