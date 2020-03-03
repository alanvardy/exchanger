defmodule ExchangerWeb.Router do
  use ExchangerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ExchangerWeb do
    pipe_through :api
  end
end
