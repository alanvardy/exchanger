defmodule Exchanger.Accounts.Wallet do
  @moduledoc """
  An immutable container that holds transactions of a single currency
  """
  use Exchanger.Schema
  alias Exchanger.Accounts.{Transaction, User}

  @required_attributes [:currency, :user_id]
  @currencies Application.get_env(:exchanger, :currencies)

  @type queryable :: Ecto.Queryable.t()
  @type currency :: String.t()
  @type id :: pos_integer

  typed_schema "wallets" do
    field :currency, :string, null: false
    belongs_to :user, User
    has_many :sent_transactions, Transaction, foreign_key: :from_wallet_id
    has_many :received_transactions, Transaction, foreign_key: :to_wallet_id

    timestamps()
  end

  @spec create_changeset(map) :: Ecto.Changeset.t()
  @doc false
  def create_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @required_attributes)
    |> validate_required(@required_attributes)
    |> validate_inclusion(:currency, @currencies)
  end

  @spec where_user_id(queryable, id) :: Ecto.Query.t()
  @spec where_user_id(id) :: Ecto.Query.t()
  def where_user_id(query \\ __MODULE__, user_id) do
    from(q in query, where: q.user_id == ^user_id)
  end

  @spec where_currency(queryable, currency) :: Ecto.Query.t()
  @spec where_currency(currency) :: Ecto.Query.t()
  def where_currency(query \\ __MODULE__, currency) do
    from(q in query, where: q.currency == ^currency)
  end
end
