BlueBird.start()
ExUnit.start(formatters: [ExUnit.CLIFormatter, BlueBird.Formatter])

Ecto.Adapters.SQL.Sandbox.mode(ExBackend.Repo, :manual)
{:ok, _} = Application.ensure_all_started(:fake_server)
