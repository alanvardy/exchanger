defmodule Exchanger.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Exchange.Accounts.Wallet

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
