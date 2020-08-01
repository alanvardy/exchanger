defmodule Exchanger.Factory do
  @moduledoc """
    ExMachina fixtures for test cases.
  """
  use ExMachina.Ecto, repo: Exchanger.Repo
  alias Exchanger.Accounts.{Transaction, User, Wallet}

  @currencies Application.get_env(:exchanger, :currencies)

  @spec transfer_factory :: Transaction.t()
  def transfer_factory do
    %Transaction{
      from_currency: currency(),
      from_amount: pos_integer(),
      to_currency: currency(),
      to_amount: pos_integer(),
      exchange_rate: float(0.1, 10),
      type: "transfer"
    }
  end

  @spec deposit_factory :: Transaction.t()
  def deposit_factory do
    %Transaction{
      to_currency: currency(),
      to_amount: pos_integer(),
      exchange_rate: float(0.1, 10),
      type: "deposit"
    }
  end

  @spec user_factory :: User.t()
  def user_factory do
    %User{
      first_name: sequence(:first_name, &"Jane#{&1}"),
      last_name: sequence(:last_name, &"Smith#{&1}")
    }
  end

  @spec wallet_factory :: Wallet.t()
  def wallet_factory do
    %Wallet{
      currency: currency()
    }
  end

  defp currency, do: Enum.random(@currencies)
  defp pos_integer, do: Enum.random(500..100_000_000)
  defp float(a, b), do: a + :rand.uniform() * (b - a)
end
