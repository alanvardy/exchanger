defmodule Exchanger.ExchangeRate.Updater do
  @moduledoc "Periodically polls the exchange rate API and updates Store"
  use GenServer
  alias Exchanger.ExchangeRate.{Client, Store}
  alias ExchangerWeb.ExchangeRateChannel
  require Logger

  @time_between_requests Application.get_env(:exchanger, :currency_refresh)
  @time_between_rounds @time_between_requests * 5

  @spec start_link(list) :: :ignore | {:error, any} | {:ok, pid}
  def start_link({currencies, caller_pid}) do
    store = get_store_name(caller_pid)
    GenServer.start_link(__MODULE__, %{currencies: currencies, store: store})
  end

  @impl true
  @spec init(any) :: {:ok, %{currencies: [map]}}
  def init(state) do
    tick()

    {:ok, state}
  end

  @impl true
  @spec handle_info(:tick, map) :: {:noreply, map}
  def handle_info(:tick, state) do
    update_rates(state)

    tick()
    {:noreply, state}
  end

  defp tick do
    Process.send_after(self(), :tick, @time_between_rounds)
  end

  defp update_rates(%{currencies: currencies, store: store}) do
    for from_currency <- currencies, to_currency <- currencies, from_currency != to_currency do
      case Client.get_rate(from_currency, to_currency) do
        {:ok, rate} ->
          rate
          |> Store.update(store)
          |> ExchangeRateChannel.publish()

        {:error, message} ->
          Logger.error("Could not get rate: #{message}")
      end

      :timer.sleep(@time_between_requests)
    end
  end

  defp get_store_name(caller_pid) do
    case Application.get_env(:exchanger, :env) do
      :test -> :"store#{inspect(caller_pid)}"
      _other -> Store
    end
  end
end
