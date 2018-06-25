{ :ok, _ } = Dummy.Repo.start_link
ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Dummy.Repo, :manual)
