use Mix.Config

# Configure your database
config :exchanger, Exchanger.Repo,
  username: "postgres",
  password: "postgres",
  database: "exchanger_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  port: 6000

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :exchanger, ExchangerWeb.Endpoint,
  http: [port: 4002],
  server: false

config :exchanger,
  currencies: [:USD, :CAD],
  currency_refresh: 20,
  api_client: Exchanger.ExchangeRate.Client.Local

# Print only warnings and errors during test
config :logger, level: :warn
