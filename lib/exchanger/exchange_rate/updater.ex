defmodule Exchanger.ExchangeRate.Updater do
  @moduledoc "Periodically polls the exchange rate API and updates Store"
  use GenServer
  alias Exchanger.ExchangeRate.{Client, Store}
  require Logger

  @time_between_requests Application.get_env(:exchanger, :currency_refresh)
  @time_between_rounds @time_between_requests * 5

  @spec start_link(list) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(default) when is_list(default) do
    GenServer.start_link(__MODULE__, default)
  end

  @impl true
  @spec init(any) :: {:ok, %{currencies: [map]}}
  def init(currencies) do
    tick()

    {:ok, currencies}
  end

  @impl true
  @spec handle_info(:tick, map) :: {:noreply, map}
  def handle_info(:tick, currencies) do
    update_rates(currencies)

    tick()
    {:noreply, currencies}
  end

  defp tick do
    Process.send_after(self(), :tick, @time_between_rounds)
  end

  defp update_rates(currencies) do
    for from_currency <- currencies, to_currency <- currencies, from_currency != to_currency do
      case Client.get_rate(from_currency, to_currency) do
        {:ok, rate} -> Store.update(rate)
        {:error, message} -> Logger.error("Could not get rate: #{message}")
      end

      :timer.sleep(@time_between_requests)
    end
  end
end
