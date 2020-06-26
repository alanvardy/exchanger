defmodule Exchanger.ExchangeRate.Updater do
  use GenServer

  alias Exchanger.ExchangeRate.Api

  # 250 ms
  @refresh_time 1000

  @impl true

  def start_link(default) when is_list(default) do
    GenServer.start_link(__MODULE__, default)
  end

  def init(opts) do
    currencies = Keyword.fetch!(opts, :currencies)
    tick()
    {:ok, %{currencies: currencies, rates: %{}}}
  end

  def handle_info(:tick, state) do
    state = update_rates(state)

    tick()
    {:noreply, state}
  end

  defp tick do
    Process.send_after(self(), :tick, @refresh_time)
  end

  defp update_rates(%{currencies: currencies, rates: rates} = state) do
    {base, list} = List.pop_at(currencies, -1)

    case Api.get(base, list) do
      {:ok, rate} -> %{currencies: [base | list], rates: Map.merge(rates, rate)}
      :error -> state
    end
  end
end
