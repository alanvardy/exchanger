defmodule ExchangerWeb.Schema do
  @moduledoc "Main schema for Absinthe"
  use Absinthe.Schema

  import_types(ExchangerWeb.Types.User)
  import_types(ExchangerWeb.Queries.User)
  import_types(ExchangerWeb.Mutations.User)

  query do
    import_fields(:user_queries)
  end

  mutation do
    import_fields(:user_mutations)
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
