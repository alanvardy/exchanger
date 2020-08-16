defmodule ExchangerWeb.Queries.User do
  @moduledoc "Absinthe queries for users"
  use Absinthe.Schema.Notation
  alias ExchangerWeb.Resolvers

  object :user_queries do
    field :users, list_of(:user) do
      arg(:first_name, :string)
      arg(:last_name, :string)
      resolve(&Resolvers.User.all/2)
    end

    field :user, :user do
      arg(:id, :id)
      arg(:first_name, :string)
      arg(:last_name, :string)
      resolve(&Resolvers.User.find/2)
    end
  end
end
