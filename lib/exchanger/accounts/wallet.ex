defmodule Exchanger.Accounts.Wallet do
  use Ecto.Schema
  import Ecto.Changeset
  alias Exchanger.Accounts.User

  @required_attributes [:currency, :user_id]

  schema "wallets" do
    field :currency, :string
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(wallet, attrs) do
    wallet
    |> cast(attrs, @required_attributes)
    |> validate_required(@required_attributes)
  end
end
