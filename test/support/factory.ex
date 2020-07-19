defmodule Exchanger.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: Exchanger.Repo

  alias Exchanger.Accounts.{Transaction, User, Wallet}

  @currencies Application.get_env(:exchanger, :currencies)

  def transaction_factory do
    from_user = insert(:user)
    to_user = insert(:user)
    %Transaction{
      from_user: from_user,
      from_wallet: build(:wallet, user: from_user),
      to_user: to_user,
      to_wallet: build(:wallet, user: to_user),
      from_currency: currency(),
      from_amount: pos_integer(),
      to_currency: currency(),
      to_amount: pos_integer(),
      exchange_rate: float(0.1, 10)
    }
  end

  def user_factory do
    %User{
      first_name: sequence(:first_name, &"Jane#{&1}"),
      last_name: sequence(:last_name, &"Smith#{&1}")
    }
  end

  def wallet_factory do
    %Wallet{
      currency: currency(),
      user: build(:user)
    }
  end

  defp currency, do: Enum.random(@currencies)
  defp pos_integer, do: Enum.random(500..100_000_000)
  defp float(a, b), do: a + :rand.uniform() * (b-a)
end
