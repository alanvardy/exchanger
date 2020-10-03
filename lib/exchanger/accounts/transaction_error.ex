defmodule Exchanger.Accounts.TransactionError do
  defexception [:message, :reason, :currency, :wallet_id, :amount]

  @spec message(map) :: String.t()
  def message(%{reason: :wrong_currency, currency: currency, wallet_id: wallet_id}) do
    "Wrong currency for wallet id #{wallet_id}: #{currency}"
  end

  def message(%{reason: :invalid_amount, amount: amount, wallet_id: wallet_id}) do
    "Invalid amount for wallet id #{wallet_id}: #{amount}"
  end
end
