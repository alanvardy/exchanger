defmodule ExchangerWeb.Schema do
  @moduledoc "Main schema for Absinthe"
  use Absinthe.Schema

  import_types(ExchangerWeb.Types.User)
  # import_types(ExchangerWeb.Types.Preference)
  # import_types(ExchangerWeb.Types.Metric)
  import_types(ExchangerWeb.Queries.User)
  # import_types(ExchangerWeb.Queries.Preference)
  # import_types(ExchangerWeb.Queries.Metric)
  import_types(ExchangerWeb.Mutations.User)
  # import_types(ExchangerWeb.Mutations.Preference)
  # import_types(ExchangerWeb.Subscriptions.Preference)

  query do
    import_fields(:user_queries)
    #   import_fields :preference_queries
    #   import_fields :metric_queries
  end

  # mutation do
  #   import_fields :user_mutations
  #   import_fields :preference_mutations
  # end

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
