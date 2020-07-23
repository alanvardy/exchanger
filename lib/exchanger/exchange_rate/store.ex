defmodule Exchanger.ExchangeRate.Store do
  @moduledoc "Stores exchange rates as a map"
  use Agent

  @type currency :: String.t()

  @spec start_link(any) :: {:error, any} | {:ok, pid}
  def start_link(currencies) do
    Agent.start_link(fn -> build_rates_map(currencies) end, name: __MODULE__)
  end

  @spec rate(currency, currency) :: {:error, :rate_not_found} | {:ok, map}
  def rate(from, to) do
    case Agent.get(__MODULE__, &get_in(&1, [from, to])) do
      %{rate: _, updated: _} = data -> {:ok, data}
      _ -> {:error, :rate_not_found}
    end
  end

  @spec update(map) :: :ok
  def update(%{currencies: currencies, rate: rate, updated: updated}) do
    Agent.update(__MODULE__, &put_in(&1, currencies, %{rate: rate, updated: updated}))
  end

  defp build_rates_map(currencies) do
    Enum.map(currencies, fn c ->
      {c, Enum.map(currencies -- [c], fn cc -> {cc, nil} end) |> Enum.into(%{})}
    end)
    |> Enum.into(%{})
  end
end
