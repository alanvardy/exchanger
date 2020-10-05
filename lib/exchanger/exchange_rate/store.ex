defmodule Exchanger.ExchangeRate.Store do
  @moduledoc "Stores exchange rates as a map"
  use Agent
  alias Exchanger.ExchangeRate.ExchangeRate

  @type currency :: String.t()
  @type rate_response :: {:error, :rate_not_found} | {:ok, %{rate: float, updated: DateTime.t()}}

  @spec start_link(any) :: {:error, any} | {:ok, pid}
  def start_link(caller_pid) do
    Agent.start_link(fn -> %{} end, name: get_store_name(caller_pid))
  end

  @spec fetch_rate(currency, currency, pid) :: rate_response
  def fetch_rate(rate, rate, _caller_pid), do: {:ok, %{rate: 1, updated: Timex.now()}}

  def fetch_rate(from, to, caller_pid) do
    store = get_store_name(caller_pid)

    case Agent.get(store, &Map.get(&1, from <> to)) do
      %{rate: _rate, updated: _updated} = data -> {:ok, data}
      nil -> {:error, :rate_not_found}
    end
  end

  @spec update(ExchangeRate.t(), String.t()) :: ExchangeRate.t()
  def update(
        %ExchangeRate{from: from, to: to, rate: rate, updated: updated} = exchange_rate,
        store_name
      ) do
    Agent.update(store_name, &Map.put(&1, from <> to, %{rate: rate, updated: updated}))

    exchange_rate
  end

  defp get_store_name(caller_pid) do
    case Application.get_env(:exchanger, :env) do
      :test -> :"store#{inspect(caller_pid)}"
      _other -> __MODULE__
    end
  end
end
