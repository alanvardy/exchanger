defmodule Exchanger.ExchangeRate.Updater do
  use GenServer

  alias Exchanger.ExchangeRate.Handler

  # 250 ms
  @refresh_time 250

  @impl true
  def init(opts) do
    currencies = Keyword.fetch!(opts, :currencies)
    current = List.first(currencies)
    {:ok, %{currencies: currencies, current: current}}
  end

  def handle_info(:tick, state do
    state = Handler.update_rates(store)
    Process.send_after(self(), :tick, @refresh_time)
    {:noreply, state}
  end

  defp tick() do
    Process.send_after(self(), :tick, @refresh_time)
  end
end
