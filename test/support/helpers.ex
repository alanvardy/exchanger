defmodule Exchanger.Helpers do
  @moduledoc """
  Test helpers, imported into all test files
  """
  import ExUnit.Assertions
  alias Exchanger.Accounts
  alias Exchanger.Accounts.Wallet
  alias ExchangerWeb.GraphQL.Schema

  @incomparables [:inserted_at, :updated_at, :id, :from_user, :from_wallet, :to_user, :to_wallet]

  @spec run_schema(String.t(), %{optional(String.t()) => any()}) :: any
  def run_schema(document, variables) do
    assert {:ok, results} = Absinthe.run(document, Schema, variables: variables)
    results
  end

  @spec deposit_in_wallet(Exchanger.Accounts.Wallet.t(), any) ::
          {:ok, Exchanger.Accounts.Transaction.t()}
  def deposit_in_wallet(%Wallet{user_id: user_id, currency: currency}, amount) do
    assert {:ok, _transaction} =
             Accounts.create_deposit(%{
               to_user_id: user_id,
               to_amount: amount,
               to_currency: currency
             })
  end

  @doc """
  Compares maps/structs or lists of maps/structs together after stripping
  out association and timestamp data, and converting structs to maps.
  This enables the comparison of params with the created struct,
  or an ex_machina return value with a database sourced value.
  """
  @spec assert_comparable([map] | map, [map] | map) :: true
  def assert_comparable([], []), do: true

  def assert_comparable([head1 | tail1], [head2 | tail2]) do
    assert_comparable(head1, head2)
    assert_comparable(tail1, tail2)
  end

  def assert_comparable(%_struct{} = struct, map) do
    comparables = get_comparables(struct)

    new_map =
      struct
      |> Map.from_struct()
      |> Map.take(comparables)

    old_map = Map.take(map, comparables)

    assert old_map == new_map
  end

  def assert_comparable(map, %_struct{} = struct) when is_map(map),
    do: assert_comparable(struct, map)

  # Returns a list of values to compare by
  @spec get_comparables(map) :: [atom]
  defp get_comparables(struct) do
    by_field =
      struct
      |> Map.from_struct()
      |> Enum.reject(fn {_k, v} -> v in [nil, ""] end)
      |> Enum.map(fn {k, _v} -> k end)

    struct
    |> Map.get(:__struct__)
    |> apply(:__schema__, [:fields])
    |> Enum.reject(fn key -> key in @incomparables end)
    |> Enum.reject(&ends_with_id?/1)
    |> Enum.filter(fn key -> Enum.member?(by_field, key) end)
  end

  # Get rid of :user_id, :site_id etc.
  @spec ends_with_id?(atom) :: boolean
  defp ends_with_id?(key), do: Regex.match?(~r/_id$/, Atom.to_string(key))
end
