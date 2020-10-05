defmodule Exchanger.ExchangeRateTest do
  use Exchanger.DataCase

  alias Exchanger.Accounts.Balance
  alias Exchanger.ExchangeRate

  setup_all do
    start_exchange_rate_processes(["USD", "CAD"])
  end

  describe "fetch/3" do
    test "can get an exchange rate" do
      assert {:ok, %{rate: 1.34, updated: %DateTime{}}} = ExchangeRate.fetch("USD", "CAD", self())
      assert {:ok, %{rate: 0.75, updated: %DateTime{}}} = ExchangeRate.fetch("CAD", "USD", self())
      assert {:ok, %{rate: 1, updated: %DateTime{}}} = ExchangeRate.fetch("CAD", "CAD", self())
      assert {:ok, %{rate: 1, updated: %DateTime{}}} = ExchangeRate.fetch("USD", "USD", self())
    end

    test "cannot get rates for other currencies" do
      assert {:error, :rate_not_found} = ExchangeRate.fetch("AWG", "AUD", self())
    end
  end

  describe "equivalent_in_currency/2" do
    test "Doesn't change the amount when converted to same currency" do
      %Balance{amount: 20} = balance = build(:balance)

      assert {:ok, %Balance{amount: 20, currency: "USD"}} =
               ExchangeRate.equivalent_in_currency(balance, "USD")
    end

    test "Can convert to other currencies" do
      %Balance{amount: 20} = balance = build(:balance)

      assert {:ok, %Balance{amount: 26, currency: "CAD"}} =
               ExchangeRate.equivalent_in_currency(balance, "CAD")
    end
  end
end
