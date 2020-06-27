defmodule Exchanger.Accounts.User do
  @moduledoc """
  A record of a person with multiple wallets holding
  multiple transactions
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Exchanger.Accounts.Wallet

  schema "users" do
    field :first_name, :string
    field :last_name, :string
    has_many :wallets, Wallet

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name])
    |> validate_required([:first_name, :last_name])
  end
end
