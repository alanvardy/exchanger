defmodule Exchanger.Accounts.Transaction do
  @moduledoc "An immutable record of financial transfers between wallets"
  use Exchanger.Schema
  alias Exchanger.Accounts.{TransactionError, User, Wallet}

  @deposit_attrs [:to_amount, :to_currency, :to_user_id, :to_wallet_id, :type]
  # @transfer_attrs [:from_amount, :from_currency, :to_amount, :to_currency, :exchange_rate] ++
  #                   [:from_user_id, :to_user_id, :from_wallet_id, :to_wallet_id]
  @currencies Application.get_env(:exchanger, :currencies)
  @types ["deposit", "withdrawal", "transfer"]

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

  @spec create_deposit_changeset(wallet, currency, amount) :: changeset
  def create_deposit_changeset(%Wallet{currency: currency} = wallet, currency, amount) do
    %Wallet{id: id, user_id: user_id} = wallet

    attrs = %{
      to_user_id: user_id,
      to_currency: currency,
      to_amount: amount,
      to_wallet_id: id,
      type: "deposit"
    }

    %__MODULE__{}
    |> cast(attrs, @deposit_attrs)
    |> validate_required(@deposit_attrs)
    |> validate_inclusion(:to_currency, @currencies)
    |> validate_number(:to_amount, greater_than_or_equal_to: @minimum_transfer)
    |> validate_number(:to_amount, less_than_or_equal_to: @maximum_transfer)
    |> validate_inclusion(:type, @types)
  end

  def create_deposit_changeset(%Wallet{id: id}, currency, _amount) do
    raise TransactionError, reason: :wrong_currency, currency: currency, wallet_id: id
  end

  # @spec create_transfer_changeset(wallet, wallet, amount, exchange_rate) :: changeset
  # def create_transfer_changeset(from_wallet, to_wallet, amount, exchange_rate) do
  #   %Wallet{id: from_wallet_id, user_id: from_user_id, currency: from_currency} = from_wallet
  #   %Wallet{id: to_wallet_id, user_id: to_user_id, currency: to_currency} = to_wallet

  #   attrs = %{
  #     type: "transfer",
  #     from_user_id: from_user_id,
  #     from_wallet_id: from_wallet_id,
  #     to_user_id: to_user_id,
  #     to_wallet_id: to_wallet_id,
  #     from_amount: amount,
  #     from_currency: from_currency,
  #     to_currency: to_currency,
  #     exchange_rate: exchange_rate,
  #     to_amount: amount * exchange_rate
  #   }

  #   %__MODULE__{}
  #   |> cast(attrs, @transfer_attrs)
  #   |> validate_required(@transfer_attrs)
  #   |> validate_inclusion(:from_currency, @currencies)
  #   |> validate_inclusion(:to_currency, @currencies)
  #   |> validate_inclusion(:type, @types)
  # end
end
