defmodule Exchanger.Accounts.Transaction do
  @moduledoc "An immutable record of financial transfers between wallets"
  use Exchanger.Schema
  alias Exchanger.Accounts.{TransactionError, User, Wallet}

  @deposit_attrs [:to_amount, :to_currency, :to_user_id, :to_wallet_id, :type]
  @withdrawal_attrs [:from_amount, :from_currency, :from_user_id, :from_wallet_id, :type]
  @transfer_attrs [:exchange_rate | @deposit_attrs] ++ @withdrawal_attrs
  @currencies Application.get_env(:exchanger, :currencies)

  @type wallet :: Wallet.t()
  @type changeset :: Ecto.Changeset.t()
  @type currency :: String.t()
  @type amount :: pos_integer()
  @type exchange_rate :: float()

  # 5 dollars
  @minimum_transfer 500
  # 1 million dollars
  @maximum_transfer 100_000_000

  typed_schema "transactions" do
    belongs_to :from_user, User
    belongs_to :from_wallet, Wallet
    belongs_to :to_user, User
    belongs_to :to_wallet, Wallet
    field :from_amount, :integer
    field :from_currency, :string
    field :to_amount, :integer
    field :to_currency, :string
    field :exchange_rate, :float
    field :type, :string, null: false

    timestamps()
  end

  @spec create_deposit_changeset(map) :: changeset
  def create_deposit_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @deposit_attrs)
    |> validate_required(@deposit_attrs)
    |> validate_inclusion(:to_currency, @currencies)
    |> validate_number(:to_amount, greater_than_or_equal_to: @minimum_transfer)
    |> validate_number(:to_amount, less_than_or_equal_to: @maximum_transfer)
    |> validate_inclusion(:type, ["deposit"])
  end

  @spec create_withdrawal_changeset(map) :: changeset
  def create_withdrawal_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @withdrawal_attrs)
    |> validate_required(@withdrawal_attrs)
    |> validate_inclusion(:from_currency, @currencies)
    |> validate_number(:from_amount, greater_than_or_equal_to: @minimum_transfer)
    |> validate_number(:from_amount, less_than_or_equal_to: @maximum_transfer)
    |> validate_inclusion(:type, ["withdrawal"])
  end

  @spec create_deposit_changeset(wallet, currency, amount) :: changeset
  def create_deposit_changeset(%Wallet{id: id}, currency, _amount) do
    raise TransactionError, reason: :wrong_currency, currency: currency, wallet_id: id
  end

  @spec create_transfer_changeset(map) :: changeset
  def create_transfer_changeset(%{to_wallet_id: to_wallet_id, to_amount: nil}) do
    raise TransactionError, reason: :invalid_amount, amount: nil, wallet_id: to_wallet_id
  end

  def create_transfer_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @transfer_attrs)
    |> validate_required(@transfer_attrs)
    |> validate_inclusion(:from_currency, @currencies)
    |> validate_inclusion(:to_currency, @currencies)
    |> validate_inclusion(:type, ["transfer"])
  end
end
