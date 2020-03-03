defmodule Exchanger.Repo do
  use Ecto.Repo,
    otp_app: :exchanger,
    adapter: Ecto.Adapters.Postgres
end
