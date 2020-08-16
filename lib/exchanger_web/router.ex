defmodule ExchangerWeb.Router do
  use ExchangerWeb, :router

  scope "/" do
    forward "/api", Absinthe.Plug, schema: ExchangerWeb.Schema

    if Mix.env() !== :prod do
      forward "/graphiql",
              Absinthe.Plug.GraphiQL,
              schema: ExchangerWeb.Schema,
              socket: ExchangerWeb.UserSocket,
              interface: :playground
    end
  end
end
