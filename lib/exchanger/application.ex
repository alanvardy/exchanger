defmodule Exchanger.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @spec start(any, any) :: {:error, any} | {:ok, pid}
  @currencies Application.get_env(:exchanger, :currencies)

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {Exchanger.ExchangeRate.Updater, @currencies},
      {Exchanger.ExchangeRate.Store, @currencies},
      {Phoenix.PubSub, [name: Exchanger.PubSub, adapter: Phoenix.PubSub.PG2]},
      # Start the Ecto repository
      Exchanger.Repo,
      # Start the endpoint when the application starts
      ExchangerWeb.Endpoint
      # Starts a worker by calling: Exchanger.Worker.start_link(arg)
      # {Exchanger.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Exchanger.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @spec config_change(any, any, any) :: :ok
  def config_change(changed, _new, removed) do
    ExchangerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
