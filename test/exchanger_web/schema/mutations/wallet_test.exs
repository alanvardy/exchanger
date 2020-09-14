defmodule ExchangerWeb.Schema.Mutations.WalletTest do
  use Exchanger.DataCase, async: true
  alias Exchanger.Accounts

  @user_params %{
    "first_name" => "Duffy",
    "last_name" => "Dogooder"
  }

  @create_wallet_doc """
    mutation createWallet($user_id: ID, $currency: String) {
      create_wallet(user_id: $user_id, currency: $currency) {
        currency
        balance
      }
    }
  """

  describe "@create_wallet" do
    test "creates a wallet" do
      user = create_user(@user_params)
      {:ok, wallets} = Accounts.all_wallets(%{})
      assert Enum.empty?(wallets)

      run_schema(@create_wallet_doc, %{"currency" => "USD", "user_id" => user.id})

      {:ok, wallets} = Accounts.all_wallets(%{})
      assert Enum.count(wallets) == 1
      assert List.first(wallets).currency == "USD"
      assert List.first(wallets).user_id == user.id
    end
  end
end
