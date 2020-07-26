defmodule Exchanger.Accounts.TransactionError do
  defexception [:message, :reason, :currency, :wallet_id]

  def message(%{reason: :wrong_currency, currency: currency, wallet_id: wallet_id}) do
    "Wrong currency for wallet id #{wallet_id}: #{currency}"
  end
end
