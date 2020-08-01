defmodule Exchanger.Accounts.User do
  @moduledoc """
  A record of a person with multiple wallets holding
  multiple transactions
  """
  use Exchanger.Schema
  alias Exchanger.Accounts.{Transaction, Wallet}

  typed_schema "users" do
    field :first_name, :string, null: false
    field :last_name, :string, null: false
    has_many :wallets, Wallet
    has_many :sent_transactions, Transaction, foreign_key: :from_user_id
    has_many :received_transactions, Transaction, foreign_key: :to_user_id

    timestamps()
  end

  # @spec changeset(t, map) :: Ecto.Changeset.t()
  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name])
    |> validate_required([:first_name, :last_name])
  end

  def by_id(query \\ __MODULE__, id) do
    from(q in query, where: q.id == ^id)
  end

  def with_wallets(query \\ __MODULE__) do
    from(q in query, preload: :wallets)
  end
end
