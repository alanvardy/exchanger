defmodule ExchangerWeb.Mutations.User do
  @moduledoc "User Mutations for Absinthe"
  use Absinthe.Schema.Notation
  alias ExchangerWeb.Resolvers

  object :user_mutations do
    field :create_user, :user do
      arg :first_name, :string
      arg :last_name, :string
      resolve &Resolvers.User.create/2
    end

    field :update_user, :user do
      arg :id, :id
      arg :first_name, :string
      arg :last_name, :string

      resolve &Resolvers.User.update/2
    end
  end
end
