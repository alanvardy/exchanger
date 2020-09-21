defmodule ExchangerWeb.Schema do
  @moduledoc "Main schema for Absinthe"
  use Absinthe.Schema

  import_types Absinthe.Type.Custom
  import_types(ExchangerWeb.Types.Balance)
  import_types(ExchangerWeb.Types.Transaction)
  import_types(ExchangerWeb.Types.User)
  import_types(ExchangerWeb.Types.Wallet)
  import_types(ExchangerWeb.Queries.Balance)
  import_types(ExchangerWeb.Queries.Transaction)
  import_types(ExchangerWeb.Queries.User)
  import_types(ExchangerWeb.Queries.Wallet)
  import_types(ExchangerWeb.Mutations.Transaction)
  import_types(ExchangerWeb.Mutations.User)
  import_types(ExchangerWeb.Mutations.Wallet)

  query do
    import_fields(:balance_queries)
    import_fields(:transaction_queries)
    import_fields(:user_queries)
    import_fields(:wallet_queries)
  end

  mutation do
    import_fields(:transaction_mutations)
    import_fields(:user_mutations)
    import_fields(:wallet_mutations)
  end

  # subscription do
  #   import_fields :preference_subscriptions
  # end

  @spec context(map) :: map
  def context(ctx) do
    source = Dataloader.Ecto.new(Exchanger.Repo)

    dataloader =
      Dataloader.new()
      |> Dataloader.add_source(Exchanger.Accounts, source)

    Map.put(ctx, :loader, dataloader)
  end

  @spec plugins :: [atom]
  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end
end
