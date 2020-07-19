defmodule Exchanger.Accounts.Wallet do
  @moduledoc """
  An immutable container that holds transactions of a single currency
  """
  use TypedEctoSchema
  import Ecto.Changeset
  alias Exchanger.Accounts.{Transaction, User}

  @required_attributes [:currency, :user_id]
  @currencies Application.get_env(:exchanger, :currencies)

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
end
