defmodule Exchanger.ExchangeRateTest do
  use Exchanger.DataCase

  alias Exchanger.ExchangeRate

  @currencies Application.get_env(:exchanger, :currencies)
  setup_all do
    start_supervised({Exchanger.ExchangeRate.Store, @currencies})
    start_supervised({Exchanger.ExchangeRate.Updater, @currencies})

    # Give the Updater time to update Store
    :timer.sleep(1000)
    :ok
  end

  describe "get_rate/2" do
    test "can get an exchange rate" do
      assert {:ok, %{rate: 1.34, updated: %DateTime{}}} = ExchangeRate.fetch("USD", "CAD")
      assert {:ok, %{rate: 0.75, updated: %DateTime{}}} = ExchangeRate.fetch("CAD", "USD")
    end

    test "cannot get rates for other currencies" do
      assert {:error, :rate_not_found} = ExchangeRate.fetch("AWG", "AUD")
    end
  end
end
