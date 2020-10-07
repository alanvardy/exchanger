defmodule Exchanger.Accounts.User do
  @moduledoc """
  A record of a person with multiple wallets holding
  multiple transactions
  """
  use Exchanger.Schema
  alias Exchanger.Accounts.{Transaction, Wallet}
  alias Ecto.{Changeset, Query, Queryable}

  @type id :: pos_integer

  typed_schema "users" do
    field :first_name, :string, null: false
    field :last_name, :string, null: false
    has_many :wallets, Wallet
    has_many :sent_transactions, Transaction, foreign_key: :from_user_id
    has_many :received_transactions, Transaction, foreign_key: :to_user_id

    timestamps()
  end

  @spec create_changeset(map) :: Changeset.t()
  def create_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:first_name, :last_name])
    |> validate_required([:first_name, :last_name])
  end

  @spec changeset(t(), map) :: Changeset.t()
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name])
    |> validate_required([:first_name, :last_name])
  end

  @spec by_id(id) :: Query.t()
  @spec by_id(Queryable.t(), id) :: Query.t()
  def by_id(query \\ __MODULE__, id) do
    where(query, [q], q.id == ^id)
  end

  @spec with_wallets(Ecto.Queryable.t()) :: Ecto.Query.t()
  def with_wallets(query \\ __MODULE__) do
    preload(query, [q], :wallets)
  end
end
