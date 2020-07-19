defmodule Exchanger.Accounts.Transaction do
  @moduledoc "An immutable record of financial transfers between wallets"
  use TypedEctoSchema
  import Ecto.Changeset
  alias Exchanger.Accounts.{User, Wallet}

  @required_attributes [:from_amount, :from_currency, :to_amount, :to_currency, :exchange_rate] ++
                         [:from_user_id, :to_user_id, :from_wallet_id, :to_wallet_id]
  @currencies Application.get_env(:exchanger, :currencies)

  typed_schema "transactions" do
    belongs_to :from_user, User
    belongs_to :from_wallet, Wallet
    belongs_to :to_user, User
    belongs_to :to_wallet, Wallet
    field :from_amount, :integer, null: false
    field :from_currency, :string, null: false
    field :to_amount, :integer, null: false
    field :to_currency, :string, null: false
    field :exchange_rate, :float, null: false

    timestamps()
  end

  @spec create_changeset(map) :: Ecto.Changeset.t()
  @doc false
  def create_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @required_attributes)
    |> validate_required(@required_attributes)
    |> validate_inclusion(:from_currency, @currencies)
    |> validate_inclusion(:to_currency, @currencies)

    # validate that exchange rate is 1 when currencies are the same
    # Validate minimum $5 transfer
    # Validate maximum $1 million transfer.
    # Adjust amounts per currency
  end
end
