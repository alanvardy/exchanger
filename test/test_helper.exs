ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Exchanger.Repo, :manual)
{:ok, _any} = Application.ensure_all_started(:ex_machina)
