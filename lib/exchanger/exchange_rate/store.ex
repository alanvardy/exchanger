defmodule Exchanger.ExchangeRate.Store do
  @moduledoc "Stores exchange rates as a map"
  use Agent

  @type currency :: String.t()
  @type rate_response :: {:error, :rate_not_found} | {:ok, %{rate: float, updated: DateTime.t()}}

  @spec start_link(any) :: {:error, any} | {:ok, pid}
  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  @spec fetch_rate(currency, currency) :: rate_response
  def fetch_rate(rate, rate), do: {:ok, %{rate: 1, updated: Timex.now()}}

  def fetch_rate(from, to) do
    case Agent.get(__MODULE__, &Map.get(&1, from <> to)) do
      %{rate: _, updated: _} = data -> {:ok, data}
      _ -> {:error, :rate_not_found}
    end
  end

  @spec update(map) :: :ok
  def update(%{currencies: {from, to}, rate: rate, updated: updated}) do
    Agent.update(__MODULE__, &Map.put(&1, from <> to, %{rate: rate, updated: updated}))
  end
end
