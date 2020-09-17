defmodule ExchangerWeb.Queries.Transaction do
  @moduledoc "Absinthe queries for users"
  use Absinthe.Schema.Notation
  alias ExchangerWeb.Resolvers

  object :transaction_queries do
    field :transactions, list_of(:transaction) do
      arg :first_name, :string
      arg :last_name, :string
      resolve &Resolvers.Transaction.all/2
    end

    field :transaction, :transaction do
      arg :id, :id
      arg :first_name, :string
      arg :last_name, :string
      resolve &Resolvers.Transaction.find/2
    end
  end
end
