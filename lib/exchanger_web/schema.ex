defmodule ExchangerWeb.Schema do
  @moduledoc "Main schema for Absinthe"
  use Absinthe.Schema

  # import_types(LearnElixirGraphqlWeb.Types.User)
  # import_types(LearnElixirGraphqlWeb.Types.Preference)
  # import_types(LearnElixirGraphqlWeb.Types.Metric)
  # import_types(LearnElixirGraphqlWeb.Queries.User)
  # import_types(LearnElixirGraphqlWeb.Queries.Preference)
  # import_types(LearnElixirGraphqlWeb.Queries.Metric)
  # import_types(LearnElixirGraphqlWeb.Mutations.User)
  # import_types(LearnElixirGraphqlWeb.Mutations.Preference)
  # import_types(LearnElixirGraphqlWeb.Subscriptions.Preference)

  query do
    #   import_fields :user_queries
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

  # @spec context(map) :: map
  # def context(ctx) do
  #   source = Dataloader.Ecto.new(LearnElixirGraphql.Repo)

  #   dataloader =
  #     Dataloader.new()
  #     |> Dataloader.add_source(LearnElixirGraphql.Accounts, source)

  #   Map.put(ctx, :loader, dataloader)
  # end

  # @spec plugins :: [atom]
  # def plugins do
  #   [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  # end
end
