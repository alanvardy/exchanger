defmodule ExchangerWeb.Router do
  use ExchangerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    pipe_through :api

    forward "/api", Absinthe.Plug, schema: ExchangerWeb.Schema
  end
end
