defmodule ExchangerWeb.GraphQL.Schema do
  @moduledoc "Main schema for Absinthe"
  use Absinthe.Schema

  import_types Absinthe.Type.Custom
  import_types ExchangerWeb.GraphQL.Types.Enums

  import_types ExchangerWeb.GraphQL.Types.Balance
  import_types ExchangerWeb.GraphQL.Types.ExchangeRate
  import_types ExchangerWeb.GraphQL.Types.Transaction
  import_types ExchangerWeb.GraphQL.Types.User
  import_types ExchangerWeb.GraphQL.Types.Wallet

  import_types ExchangerWeb.GraphQL.Queries.Balance
  import_types ExchangerWeb.GraphQL.Queries.Transaction
  import_types ExchangerWeb.GraphQL.Queries.User
  import_types ExchangerWeb.GraphQL.Queries.Wallet

  import_types ExchangerWeb.GraphQL.Mutations.Transaction
  import_types ExchangerWeb.GraphQL.Mutations.User
  import_types ExchangerWeb.GraphQL.Mutations.Wallet

  import_types ExchangerWeb.GraphQL.Subscriptions.ExchangeRate
  import_types ExchangerWeb.GraphQL.Subscriptions.User

  query do
    import_fields :balance_queries
    import_fields :transaction_queries
    import_fields :user_queries
    import_fields :wallet_queries
  end

  mutation do
    import_fields :transaction_mutations
    import_fields :user_mutations
    import_fields :wallet_mutations
  end

  subscription do
    import_fields :exchange_rate_subscriptions
    import_fields :user_subscriptions
  end

  @spec context(map) :: map
  def context(ctx) do
    source = Dataloader.Ecto.new(Exchanger.Repo)

    dataloader = Dataloader.add_source(Dataloader.new(), Exchanger.Accounts, source)

    Map.put(ctx, :loader, dataloader)
  end

  @spec plugins :: [atom]
  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end
end
