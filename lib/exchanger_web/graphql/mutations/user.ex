defmodule ExchangerWeb.GraphQL.Mutations.User do
  @moduledoc "User Mutations for Absinthe"
  use Absinthe.Schema.Notation
  alias ExchangerWeb.GraphQL.Resolvers

  object :user_mutations do
    field :create_user, :user do
      arg :first_name, non_null(:string)
      arg :last_name, non_null(:string)
      resolve &Resolvers.User.create/2
    end

    field :update_user, :user do
      arg :id, non_null(:id)
      arg :first_name, :string
      arg :last_name, :string

      resolve &Resolvers.User.update/2
    end
  end
end
