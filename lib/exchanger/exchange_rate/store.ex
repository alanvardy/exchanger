defmodule Exchanger.ExchangeRate.Store do
  @moduledoc "Stores exchange rates as a map"
  use Agent

  @type currency :: String.t()

  @spec start_link(any) :: {:error, any} | {:ok, pid}
  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  @spec rate(currency, currency) :: {:error, :rate_not_found} | {:ok, {float, DateTime}}
  def rate(from, to) do
    with value when is_map(value) <- Agent.get(__MODULE__, &Map.get(&1, from)),
         %DateTime{} = datetime <- Map.get(value, "datetime"),
         rate when is_float(rate) <- get_in(value, ["rates", to]) do
      {:ok, {rate, datetime}}
    else
      _ -> {:error, :rate_not_found}
    end
  end

  @spec update(map) :: :ok
  def update(map) do
    Agent.update(__MODULE__, &Map.merge(&1, map))
  end
end
