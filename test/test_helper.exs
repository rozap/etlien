ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Etlien.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Etlien.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(Etlien.Repo)

