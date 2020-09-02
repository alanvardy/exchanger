defmodule Exchanger.Helpers do
  @moduledoc """
  Test helpers, imported into all test files
  """
  import ExUnit.Assertions
  alias Exchanger.Accounts
  alias ExchangerWeb.Schema

  @incomparables [:inserted_at, :updated_at, :id, :from_user, :from_wallet, :to_user, :to_wallet]

  @spec run_schema(String.t(), %{optional(String.t()) => any()}) :: any
  def run_schema(document, variables) do
    assert {:ok, %{data: data}} = Absinthe.run(document, Schema, variables: variables)
    data
  end

  @doc "Creates users for a list of maps containing the paramers"
  @spec create_users([map]) :: [User.t()]
  def create_users(users_params) do
    for params <- users_params, do: create_user(params)
  end

  @doc "Creates a user from a map of parameters"
  @spec create_user(map) :: User.t()
  def create_user(user_params) do
    {:ok, user} = Accounts.create_user(user_params)
    user
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

  def assert_comparable(%_{} = struct, map) do
    comparables = get_comparables(struct)

    new_map =
      struct
      |> Map.from_struct()
      |> Map.take(comparables)

    old_map = Map.take(map, comparables)

    assert old_map == new_map
  end

  def assert_comparable(map, %_{} = struct) when is_map(map), do: assert_comparable(struct, map)

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
