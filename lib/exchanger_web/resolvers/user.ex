defmodule ExchangerWeb.Resolvers.User do
  @moduledoc "User resolvers for Absinthe"
  use Absinthe.Schema.Notation
  alias Exchanger.Accounts
  alias Exchanger.Accounts.User

  @type params :: keyword | map

  @spec all(params, any) :: {:ok, [User.t()]} | {:error, binary}
  def all(params, _) do
    Accounts.all_users(params)
  end

  @spec find(params, any) :: {:error, binary} | {:ok, User.t()}
  def find(params, _) do
    Accounts.find_user(params) |> IO.inspect(label: "16")
  end

  # @spec create(params, any) :: {:error, Ecto.Changeset.t()} | {:ok, User.t()}
  # def create(params, _) do
  #   Metrics.register_resolver_hit("create_user")
  #   Accounts.create_user(params)
  # end

  # @spec update(params, any) :: {:error, Ecto.Changeset.t()} | {:ok, User.t()}
  # def update(params, _) do
  #   Metrics.register_resolver_hit("update_user")
  #   Accounts.update_user(params)
  # end
end
