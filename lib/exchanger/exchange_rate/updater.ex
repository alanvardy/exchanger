defmodule Exchanger.ExchangeRate.Updater do
  @moduledoc "Periodically polls the exchange rate API and updates Store"
  use GenServer
  alias Exchanger.ExchangeRate.{Api, Store}

  # 250 ms
  @refresh_time 1000

  @impl true

  def start_link(default) when is_list(default) do
    GenServer.start_link(__MODULE__, default)
  end

  def init(currencies) do
    tick()
    {:ok, %{currencies: currencies}}
  end

  def handle_info(:tick, state) do
    state = update_rates(state)

    tick()
    {:noreply, state}
  end

  defp tick do
    Process.send_after(self(), :tick, @refresh_time)
  end

  defp update_rates(%{currencies: currencies} = state) do
    {base, list} = List.pop_at(currencies, -1)

    case Api.get(base, list) do
      {:ok, rate} ->
        Store.update(rate)
        %{currencies: [base | list]}

      :error ->
        state
    end
  end
end
